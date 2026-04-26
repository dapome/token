import Foundation

enum AppLinks {
    static let openAIUsageDocs = url(for: "https://platform.openai.com/docs/api-reference/usage/costs")
    static let anthropicUsageDocs = url(for: "https://docs.anthropic.com/en/api/usage-cost-api")
    static let openRouterUsageDocs = url(for: "https://openrouter.ai/docs/api-reference/credits/get-credits")
    static let openAIAdminDocs = url(for: "https://help.openai.com/en/articles/9687866-admin-and-audit-logs-api-for-the-api-platform")
    static let anthropicAdminDocs = url(for: "https://docs.anthropic.com/en/api/administration-api")
    static let openRouterAdminDocs = url(for: "https://openrouter.ai/docs/guides/overview/auth/management-api-keys")
    static let chatGPTUsage = url(for: "https://chatgpt.com/codex/cloud/settings/analytics")
    static let claudeUsage = url(for: "https://claude.ai/settings/usage")
    static let openRouterCredits = url(for: "https://openrouter.ai/credits")

    private static func url(for rawValue: String) -> URL {
        guard let url = URL(string: rawValue) else {
            preconditionFailure("Invalid URL: \(rawValue)")
        }

        return url
    }
}
