import Foundation

struct AnthropicUsageService: Sendable {
    func fetchSnapshot(apiKey: String, now: Date = .now) async throws -> ProviderSnapshot {
        guard apiKey.hasPrefix("sk-ant-admin") else {
            throw UsageError.invalidConfiguration(
                "Anthropic Usage & Cost endpoints require an Admin API key starting with `sk-ant-admin`. Standard Claude API keys will not work."
            )
        }

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
            todayRequests: nil,
            monthInputTokens: completedMonthTotals.inputTokens + todayTotals.inputTokens,
            monthOutputTokens: completedMonthTotals.outputTokens + todayTotals.outputTokens,
            monthRequests: nil,
            updatedAt: now,
            note: "Spend is daily, may trail the current UTC day, and excludes Priority Tier billing."
        )
    }

    private func fetchCostBuckets(apiKey: String, start: Date, end: Date) async throws -> [CostBucket] {
        let response: CostResponse = try await performRequest(
            apiKey: apiKey,
            path: "/v1/organizations/cost_report",
            queryItems: [
                URLQueryItem(name: "starting_at", value: UsageCalendar.rfc3339String(for: start)),
                URLQueryItem(name: "ending_at", value: UsageCalendar.rfc3339String(for: end)),
                URLQueryItem(name: "limit", value: "31"),
            ]
        )

        return response.data
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

        let response: UsageResponse = try await performRequest(
            apiKey: apiKey,
            path: "/v1/organizations/usage_report/messages",
            queryItems: [
                URLQueryItem(name: "starting_at", value: UsageCalendar.rfc3339String(for: start)),
                URLQueryItem(name: "ending_at", value: UsageCalendar.rfc3339String(for: end)),
                URLQueryItem(name: "bucket_width", value: bucketWidth),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        )

        return response.data
    }

    private func performRequest<Response: Decodable>(
        apiKey: String,
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> Response {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.anthropic.com"
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw UsageError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
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
                "Anthropic rejected the key. These endpoints require an Anthropic Admin API key."
            )
        case 403:
            throw UsageError.accessUnavailable(
                "Anthropic Usage & Cost Admin API is unavailable for individual accounts and non-admin keys."
            )
        default:
            throw UsageError.requestFailed("Anthropic request failed with HTTP \(httpResponse.statusCode).")
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw UsageError.invalidPayload
        }
    }

    func aggregate(results: [UsageBucket]) -> UsageTotals {
        results.reduce(into: UsageTotals()) { partialResult, bucket in
            for result in bucket.results {
                partialResult.inputTokens += result.totalInputTokens
                partialResult.outputTokens += result.outputTokens
            }
        }
    }
}

extension AnthropicUsageService {
    struct CostResponse: Decodable {
        let data: [CostBucket]
    }

    struct CostBucket: Decodable {
        let results: [CostResult]

        var totalCost: Decimal {
            results.reduce(into: Decimal.zero) { partialResult, result in
                partialResult += result.amount
            }
        }
    }

    struct CostResult: Decodable {
        let amount: Decimal

        enum CodingKeys: String, CodingKey {
            case amount
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let rawValue = try? container.decode(String.self, forKey: .amount),
               let amount = Decimal(string: rawValue, locale: Locale(identifier: "en_US_POSIX")) {
                self.amount = Self.normalizeToUSD(amount)
                return
            }

            if let wrappedAmount = try? container.decode(WrappedAmount.self, forKey: .amount) {
                self.amount = Self.normalizeToUSD(wrappedAmount.decimalValue)
                return
            }

            throw UsageError.invalidPayload
        }

        private static func normalizeToUSD(_ minorUnitAmount: Decimal) -> Decimal {
            // Anthropic reports cost amounts in the lowest currency unit (cents for USD).
            minorUnitAmount / 100
        }
    }

    struct UsageResponse: Decodable {
        let data: [UsageBucket]
    }

    struct UsageBucket: Decodable {
        let results: [UsageResult]
    }

    struct UsageResult: Decodable {
        let uncachedInputTokens: Int
        let cacheCreationInputTokens: Int
        let cacheReadInputTokens: Int
        let outputTokens: Int

        enum CodingKeys: String, CodingKey {
            case uncachedInputTokens = "uncached_input_tokens"
            case inputTokens = "input_tokens"
            case cacheCreation = "cache_creation"
            case cacheCreationInputTokens = "cache_creation_input_tokens"
            case cacheReadInputTokens = "cache_read_input_tokens"
            case outputTokens = "output_tokens"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let cacheCreationMap = try container.decodeIfPresent([String: Int].self, forKey: .cacheCreation) ?? [:]

            uncachedInputTokens =
                try container.decodeIfPresent(Int.self, forKey: .uncachedInputTokens)
                ?? container.decodeIfPresent(Int.self, forKey: .inputTokens)
                ?? 0
            cacheCreationInputTokens =
                cacheCreationMap.values.reduce(0, +)
                + (try container.decodeIfPresent(Int.self, forKey: .cacheCreationInputTokens) ?? 0)
            cacheReadInputTokens = try container.decodeIfPresent(Int.self, forKey: .cacheReadInputTokens) ?? 0
            outputTokens = try container.decodeIfPresent(Int.self, forKey: .outputTokens) ?? 0
        }

        var totalInputTokens: Int {
            uncachedInputTokens + cacheCreationInputTokens + cacheReadInputTokens
        }
    }

    struct UsageTotals {
        var inputTokens = 0
        var outputTokens = 0
    }

    struct WrappedAmount: Decodable {
        let value: String

        var decimalValue: Decimal {
            Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? .zero
        }
    }
}
