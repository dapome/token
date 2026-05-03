import Foundation

struct OpenAIUsageService: Sendable {
    func fetchSnapshot(apiKey: String, now: Date = .now) async throws -> ProviderSnapshot {
        let monthStart = UsageCalendar.monthStart(containing: now)
        let dayStart = UsageCalendar.dayStart(containing: now)

        async let costBuckets = fetchCostBuckets(apiKey: apiKey, start: monthStart, end: now)
        async let completedMonthUsage = fetchUsageBucketsIfNeeded(
            apiKey: apiKey,
            start: monthStart,
            end: dayStart,
            bucketWidth: "1d",
            limit: 31
        )
        async let todayUsage = fetchUsageBucketsIfNeeded(
            apiKey: apiKey,
            start: dayStart,
            end: now,
            bucketWidth: "1h",
            limit: 24
        )

        let (costResults, completedMonthResults, todayResults) = try await (costBuckets, completedMonthUsage, todayUsage)
        let completedMonthTotals = aggregate(results: completedMonthResults)
        let todayTotals = aggregate(results: todayResults)

        return ProviderSnapshot(
            costMonth: costResults.reduce(into: Decimal.zero) { partialResult, bucket in
                partialResult += bucket.totalCost
            },
            costToday: nil,
            totalCredits: nil,
            totalUsage: nil,
            todayInputTokens: todayTotals.inputTokens,
            todayOutputTokens: todayTotals.outputTokens,
            todayRequests: todayTotals.requestCount,
            monthInputTokens: completedMonthTotals.inputTokens + todayTotals.inputTokens,
            monthOutputTokens: completedMonthTotals.outputTokens + todayTotals.outputTokens,
            monthRequests: completedMonthTotals.requestCount + todayTotals.requestCount,
            updatedAt: now,
            note: "Spend is reported in daily buckets and may trail the current UTC day."
        )
    }

    private func fetchCostBuckets(apiKey: String, start: Date, end: Date) async throws -> [CostBucket] {
        let payload = try await performRequest(
            apiKey: apiKey,
            path: "/v1/organization/costs",
            queryItems: [
                URLQueryItem(name: "start_time", value: UsageCalendar.unixTimestampString(for: start)),
                URLQueryItem(name: "end_time", value: UsageCalendar.unixTimestampString(for: end)),
                URLQueryItem(name: "bucket_width", value: "1d"),
                URLQueryItem(name: "limit", value: "31"),
            ]
        )

        return try parseCostBuckets(from: payload)
    }

    private func fetchUsageBucketsIfNeeded(
        apiKey: String,
        start: Date,
        end: Date,
        bucketWidth: String,
        limit: Int
    ) async throws -> [UsageBucket] {
        guard start < end else {
            return []
        }

        let payload = try await performRequest(
            apiKey: apiKey,
            path: "/v1/organization/usage/completions",
            queryItems: [
                URLQueryItem(name: "start_time", value: UsageCalendar.unixTimestampString(for: start)),
                URLQueryItem(name: "end_time", value: UsageCalendar.unixTimestampString(for: end)),
                URLQueryItem(name: "bucket_width", value: bucketWidth),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        )

        return try parseUsageBuckets(from: payload)
    }

    private func performRequest(
        apiKey: String,
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> [String: Any] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openai.com"
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw UsageError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw UsageError.unauthorized(
                "OpenAI rejected the key. These endpoints require an OpenAI Admin API key."
            )
        case 403:
            throw UsageError.accessUnavailable(
                "OpenAI blocked access to organization usage data. Confirm that the key is an Admin API key for the organization."
            )
        default:
            throw UsageError.requestFailed("OpenAI request failed with HTTP \(httpResponse.statusCode).")
        }

        let object = try? JSONSerialization.jsonObject(with: data)
        guard let payload = object as? [String: Any] else {
            throw UsageError.requestFailed("OpenAI response schema mismatch.")
        }

        return payload
    }

    func parseCostBuckets(from payload: [String: Any]) throws -> [CostBucket] {
        guard let data = payload["data"] as? [[String: Any]] else {
            throw UsageError.requestFailed("OpenAI costs response is missing `data`.")
        }

        return data.map { bucket in
            let results = bucketResults(from: bucket)
            let totalCost = results.reduce(into: Decimal.zero) { partialResult, result in
                if let amountObject = result["amount"] as? [String: Any],
                   let value = decimalValue(amountObject["value"]) {
                    partialResult += value
                } else if let value = decimalValue(result["amount"]) {
                    partialResult += value
                }
            }

            return CostBucket(totalCost: totalCost)
        }
    }

    func parseUsageBuckets(from payload: [String: Any]) throws -> [UsageBucket] {
        guard let data = payload["data"] as? [[String: Any]] else {
            throw UsageError.requestFailed("OpenAI usage response is missing `data`.")
        }

        return data.map { bucket in
            let usageResults = bucketResults(from: bucket).map { result in
                UsageResult(
                    inputTokens: intValue(result["input_tokens"]),
                    outputTokens: intValue(result["output_tokens"]),
                    numModelRequests: intValue(result["num_model_requests"])
                )
            }

            return UsageBucket(results: usageResults)
        }
    }

    private func bucketResults(from bucket: [String: Any]) -> [[String: Any]] {
        if let results = bucket["results"] as? [[String: Any]] {
            return results
        }

        if let results = bucket["result"] as? [[String: Any]] {
            return results
        }

        return []
    }

    func aggregate(results: [UsageBucket]) -> UsageTotals {
        results.reduce(into: UsageTotals()) { partialResult, bucket in
            for result in bucket.results {
                partialResult.inputTokens += result.inputTokens ?? 0
                partialResult.outputTokens += result.outputTokens ?? 0
                partialResult.requestCount += result.numModelRequests ?? 0
            }
        }
    }

    private func intValue(_ rawValue: Any?) -> Int? {
        switch rawValue {
        case let value as Int:
            value
        case let value as NSNumber:
            value.intValue
        case let value as String:
            Int(value)
        default:
            nil
        }
    }

    private func decimalValue(_ rawValue: Any?) -> Decimal? {
        switch rawValue {
        case let value as Decimal:
            value
        case let value as NSNumber:
            value.decimalValue
        case let value as String:
            Decimal(string: value, locale: Locale(identifier: "en_US_POSIX"))
        default:
            nil
        }
    }

}

extension OpenAIUsageService {
    struct CostBucket {
        let totalCost: Decimal
    }

    struct UsageBucket {
        let results: [UsageResult]
    }

    struct UsageResult {
        let inputTokens: Int?
        let outputTokens: Int?
        let numModelRequests: Int?
    }

    struct UsageTotals {
        var inputTokens = 0
        var outputTokens = 0
        var requestCount = 0
    }
}
