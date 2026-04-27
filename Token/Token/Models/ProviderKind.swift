import Foundation
import SwiftUI

enum ProviderKind: String, CaseIterable, Identifiable, Sendable {
    case openAI
    case anthropic
    case openRouter
    case gemini

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
        case .gemini:
            "Gemini API"
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
        case .gemini:
            "Gemini API key"
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
        case .gemini:
            "Paste a Gemini API key"
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
        case .gemini:
            "Requires a Google AI Studio Gemini API key. Organization-level spend reporting is limited with this key type."
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
        case .gemini:
            "Gemini"
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
        case .gemini:
            "Gemini API key usage is managed through Google AI Studio and Google Cloud billing."
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
        case .gemini:
            "gemini-api-key"
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
        case .gemini:
            AppLinks.geminiUsageDocs
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
        case .gemini:
            AppLinks.geminiAdminDocs
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
        case .gemini:
            AppLinks.geminiUsage
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
        case .gemini:
            "g.circle"
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
        case .gemini:
            .purple
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
        case .gemini:
            .indigo
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
        case .gemini:
            "Gemini API key connectivity and usage metadata"
        }
    }
}
