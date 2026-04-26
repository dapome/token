import Foundation
import SwiftUI

enum ProviderKind: String, CaseIterable, Identifiable, Sendable {
    case openAI
    case anthropic
    case openRouter

    static let subscriptionCases: [Self] = [.openAI, .anthropic]

    var id: Self { self }

    var title: String {
        switch self {
        case .openAI:
            "OpenAI API"
        case .anthropic:
            "Anthropic API"
        case .openRouter:
            "OpenRouter API"
        }
    }

    var credentialTitle: String {
        switch self {
        case .openAI:
            "OpenAI Admin key"
        case .anthropic:
            "Anthropic Admin key"
        case .openRouter:
            "OpenRouter management key"
        }
    }

    var credentialPrompt: String {
        switch self {
        case .openAI:
            "Paste an OpenAI organization admin key"
        case .anthropic:
            "Paste an Anthropic admin key"
        case .openRouter:
            "Paste an OpenRouter management key"
        }
    }

    var credentialHelpText: String {
        switch self {
        case .openAI:
            "Requires an OpenAI Admin API key created by an organization owner. Standard API keys will not work."
        case .anthropic:
            "Requires an Anthropic Admin API key. Standard Claude API keys will not work, and the Usage & Cost API is unavailable for individual accounts."
        case .openRouter:
            "Requires an OpenRouter management key. Standard OpenRouter API keys will not work for credits or key-usage reporting."
        }
    }

    var subscriptionTitle: String {
        switch self {
        case .openAI:
            "ChatGPT"
        case .anthropic:
            "Claude"
        case .openRouter:
            "OpenRouter"
        }
    }

    var subscriptionMessage: String {
        switch self {
        case .openAI:
            "ChatGPT subscription quotas are not exposed through a stable public API."
        case .anthropic:
            "Claude subscription quotas are not exposed through a stable public API."
        case .openRouter:
            "OpenRouter usage is reported through its management API rather than a subscription app."
        }
    }

    var keychainAccount: String {
        switch self {
        case .openAI:
            "openai-admin-key"
        case .anthropic:
            "anthropic-admin-key"
        case .openRouter:
            "openrouter-management-key"
        }
    }

    var usageDocsURL: URL {
        switch self {
        case .openAI:
            AppLinks.openAIUsageDocs
        case .anthropic:
            AppLinks.anthropicUsageDocs
        case .openRouter:
            AppLinks.openRouterUsageDocs
        }
    }

    var adminDocsURL: URL {
        switch self {
        case .openAI:
            AppLinks.openAIAdminDocs
        case .anthropic:
            AppLinks.anthropicAdminDocs
        case .openRouter:
            AppLinks.openRouterAdminDocs
        }
    }

    var subscriptionURL: URL {
        switch self {
        case .openAI:
            AppLinks.chatGPTUsage
        case .anthropic:
            AppLinks.claudeUsage
        case .openRouter:
            AppLinks.openRouterCredits
        }
    }

    var systemImage: String {
        switch self {
        case .openAI:
            "sparkles"
        case .anthropic:
            "brain.head.profile"
        case .openRouter:
            "arrow.triangle.branch"
        }
    }

    var accentColor: Color {
        switch self {
        case .openAI:
            .orange
        case .anthropic:
            .teal
        case .openRouter:
            .blue
        }
    }

    var secondaryAccentColor: Color {
        switch self {
        case .openAI:
            .yellow
        case .anthropic:
            .mint
        case .openRouter:
            .cyan
        }
    }

    var statusDescription: String {
        switch self {
        case .openAI:
            "Organization usage and cost reporting"
        case .anthropic:
            "Usage & cost admin reporting"
        case .openRouter:
            "Credits and API key spend reporting"
        }
    }
}
