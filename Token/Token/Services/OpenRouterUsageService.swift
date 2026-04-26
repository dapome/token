import Foundation

struct OpenRouterUsageService: Sendable {
    func fetchSnapshot(apiKey: String, now: Date = .now) async throws -> ProviderSnapshot {
        async let credits = fetchCredits(apiKey: apiKey)
        async let apiKeys = fetchAllAPIKeys(apiKey: apiKey)

        let (creditSummary, keys) = try await (credits, apiKeys)
        let enabledKeys = keys.filter { !$0.disabled }

        return ProviderSnapshot(
            costMonth: enabledKeys.reduce(into: Decimal.zero) { partialResult, key in
                partialResult += key.usageMonthly
            },
            costToday: enabledKeys.reduce(into: Decimal.zero) { partialResult, key in
                partialResult += key.usageDaily
            },
            totalCredits: creditSummary.totalCredits,
            totalUsage: creditSummary.totalUsage,
            todayInputTokens: nil,
            todayOutputTokens: nil,
            todayRequests: nil,
            monthInputTokens: nil,
            monthOutputTokens: nil,
            monthRequests: nil,
            updatedAt: now,
            note: "OpenRouter's management API reports spend by API key and credits across the account. Token counts are not exposed here, and monthly spend is aggregated from keys in the default workspace."
        )
    }

    private func fetchCredits(apiKey: String) async throws -> CreditSummary {
        let response: CreditsResponse = try await performRequest(apiKey: apiKey, path: "/credits", queryItems: [])
        return response.data
    }

    private func fetchAllAPIKeys(apiKey: String) async throws -> [APIKeySummary] {
        var allKeys: [APIKeySummary] = []
        var offset = 0

        while true {
            let response: KeysResponse = try await performRequest(
                apiKey: apiKey,
                path: "/keys",
                queryItems: [
                    URLQueryItem(name: "include_disabled", value: "false"),
                    URLQueryItem(name: "offset", value: String(offset)),
                ]
            )

            guard !response.data.isEmpty else {
                return allKeys
            }

            allKeys.append(contentsOf: response.data)
            offset += response.data.count

            if offset > 10_000 {
                return allKeys
            }
        }
    }

    private func performRequest<Response: Decodable>(
        apiKey: String,
        path: String,
        queryItems: [URLQueryItem]
    ) async throws -> Response {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "openrouter.ai"
        components.path = "/api/v1\(path)"
        components.queryItems = queryItems.isEmpty ? nil : queryItems

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
                "OpenRouter rejected the key. These endpoints require a valid OpenRouter management key. \(errorMessage(from: data) ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        case 403:
            throw UsageError.accessUnavailable(
                "OpenRouter blocked access to credits or key reporting. These endpoints require a management key rather than a standard API key. \(errorMessage(from: data) ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        default:
            let message = errorMessage(from: data) ?? "HTTP \(httpResponse.statusCode)"
            throw UsageError.requestFailed("OpenRouter request failed: \(message)")
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw UsageError.invalidPayload
        }
    }

    private func errorMessage(from data: Data) -> String? {
        let payload = try? JSONDecoder().decode(OpenRouterErrorEnvelope.self, from: data)
        return payload?.error.message
    }
}

extension OpenRouterUsageService {
    struct OpenRouterErrorEnvelope: Decodable {
        let error: OpenRouterErrorDetail
    }

    struct OpenRouterErrorDetail: Decodable {
        let message: String
    }

    struct CreditsResponse: Decodable {
        let data: CreditSummary
    }

    struct CreditSummary: Decodable {
        let totalCredits: Decimal
        let totalUsage: Decimal

        enum CodingKeys: String, CodingKey {
            case totalCredits = "total_credits"
            case totalUsage = "total_usage"
        }
    }

    struct KeysResponse: Decodable {
        let data: [APIKeySummary]
    }

    struct APIKeySummary: Decodable {
        let disabled: Bool
        let usageDaily: Decimal
        let usageMonthly: Decimal

        enum CodingKeys: String, CodingKey {
            case disabled
            case usageDaily = "usage_daily"
            case usageMonthly = "usage_monthly"
        }
    }
}
