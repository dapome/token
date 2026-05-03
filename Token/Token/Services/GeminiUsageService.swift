import Foundation

struct GeminiUsageService: Sendable {
    func fetchSnapshot(apiKey: String, now: Date = .now) async throws -> ProviderSnapshot {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw UsageError.invalidConfiguration("Gemini API key is empty.")
        }

        try await validateAPIKey(apiKey: apiKey)

        return ProviderSnapshot(
            costMonth: .zero,
            costToday: nil,
            totalCredits: nil,
            totalUsage: nil,
            todayInputTokens: nil,
            todayOutputTokens: nil,
            todayRequests: nil,
            monthInputTokens: nil,
            monthOutputTokens: nil,
            monthRequests: nil,
            updatedAt: now,
            note: "Gemini API key validation is live. Spend totals are not currently exposed through this lightweight endpoint."
        )
    }

    private func validateAPIKey(apiKey: String) async throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "generativelanguage.googleapis.com"
        components.path = "/v1beta/models"

        guard let url = components.url else {
            throw UsageError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Token/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return
        case 401:
            throw UsageError.unauthorized("Gemini rejected the key. Confirm it is a valid Google AI Studio API key.")
        case 403:
            throw UsageError.accessUnavailable("Gemini key lacks permission for model access. Check project/API settings.")
        default:
            throw UsageError.requestFailed("Gemini request failed with HTTP \(httpResponse.statusCode).")
        }
    }
}
