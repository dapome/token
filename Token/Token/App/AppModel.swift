import Foundation
import Observation

@Observable
@MainActor
final class AppModel {
    @ObservationIgnored private let keychain = KeychainStore()
    @ObservationIgnored private let openAIService = OpenAIUsageService()
    @ObservationIgnored private let anthropicService = AnthropicUsageService()
    @ObservationIgnored private let openRouterService = OpenRouterUsageService()
    @ObservationIgnored private let refreshInterval: TimeInterval = 600

    var openAIKeyDraft = ""
    var anthropicKeyDraft = ""
    var openRouterKeyDraft = ""

    private(set) var hasOpenAIKey = false
    private(set) var hasAnthropicKey = false
    private(set) var hasOpenRouterKey = false
    private(set) var openAIState: ProviderLoadState = .notConfigured
    private(set) var anthropicState: ProviderLoadState = .notConfigured
    private(set) var openRouterState: ProviderLoadState = .notConfigured
    private(set) var isRefreshing = false
    private(set) var settingsStatusMessage: String?

    @ObservationIgnored private var didStart = false
    @ObservationIgnored private var lastRefreshAt: Date?

    var lastUpdated: Date? {
        [openAIState.snapshot?.updatedAt, anthropicState.snapshot?.updatedAt, openRouterState.snapshot?.updatedAt]
            .compactMap { $0 }
            .max()
    }

    var menuBarSystemImage: String {
        if isRefreshing {
            "arrow.trianglehead.2.clockwise.rotate.90"
        } else if openAIState.errorMessage != nil || anthropicState.errorMessage != nil || openRouterState.errorMessage != nil {
            "exclamationmark.triangle.fill"
        } else {
            "chart.bar.xaxis"
        }
    }

    var menuBarAccessibilityLabel: String {
        if let lastUpdated {
            "Token, last updated \(lastUpdated.formatted(date: .omitted, time: .shortened))"
        } else {
            "Token"
        }
    }

    func start() async {
        reloadCredentialStatus()

        guard !didStart else {
            await refreshIfNeeded()
            return
        }

        didStart = true
        await refreshIfNeeded(force: true)
    }

    func refreshIfNeeded(force: Bool = false) async {
        guard force || shouldRefresh else {
            return
        }

        await refreshAll()
    }

    func refreshAll() async {
        guard !isRefreshing else {
            return
        }

        isRefreshing = true
        defer {
            isRefreshing = false
            lastRefreshAt = .now
        }

        prepareRefreshState()

        let openAIKey = hasOpenAIKey ? keychain.value(for: .openAI) : nil
        let anthropicKey = hasAnthropicKey ? keychain.value(for: .anthropic) : nil
        let openRouterKey = hasOpenRouterKey ? keychain.value(for: .openRouter) : nil
        let openAIService = openAIService
        let anthropicService = anthropicService
        let openRouterService = openRouterService

        await withTaskGroup(of: (ProviderKind, Result<ProviderSnapshot, UsageError>).self) { group in
            if let openAIKey {
                group.addTask {
                    do {
                        return (.openAI, .success(try await openAIService.fetchSnapshot(apiKey: openAIKey)))
                    } catch let error as UsageError {
                        return (.openAI, .failure(error))
                    } catch {
                        return (.openAI, .failure(.requestFailed(error.localizedDescription)))
                    }
                }
            }

            if let anthropicKey {
                group.addTask {
                    do {
                        return (.anthropic, .success(try await anthropicService.fetchSnapshot(apiKey: anthropicKey)))
                    } catch let error as UsageError {
                        return (.anthropic, .failure(error))
                    } catch {
                        return (.anthropic, .failure(.requestFailed(error.localizedDescription)))
                    }
                }
            }

            if let openRouterKey {
                group.addTask {
                    do {
                        return (.openRouter, .success(try await openRouterService.fetchSnapshot(apiKey: openRouterKey)))
                    } catch let error as UsageError {
                        return (.openRouter, .failure(error))
                    } catch {
                        return (.openRouter, .failure(.requestFailed(error.localizedDescription)))
                    }
                }
            }

            for await (provider, result) in group {
                apply(result, for: provider)
            }
        }
    }

    func saveOpenAIKey() async {
        await saveCredential(for: .openAI, rawValue: openAIKeyDraft)
    }

    func saveAnthropicKey() async {
        await saveCredential(for: .anthropic, rawValue: anthropicKeyDraft)
    }

    func removeOpenAIKey() async {
        await removeCredential(for: .openAI)
    }

    func removeAnthropicKey() async {
        await removeCredential(for: .anthropic)
    }

    func saveOpenRouterKey() async {
        await saveCredential(for: .openRouter, rawValue: openRouterKeyDraft)
    }

    func removeOpenRouterKey() async {
        await removeCredential(for: .openRouter)
    }

    private var shouldRefresh: Bool {
        guard let lastRefreshAt else {
            return true
        }

        return Date.now.timeIntervalSince(lastRefreshAt) >= refreshInterval
    }

    private func reloadCredentialStatus() {
        hasOpenAIKey = keychain.value(for: .openAI) != nil
        hasAnthropicKey = keychain.value(for: .anthropic) != nil
        hasOpenRouterKey = keychain.value(for: .openRouter) != nil

        if !hasOpenAIKey {
            openAIState = .notConfigured
        }

        if !hasAnthropicKey {
            anthropicState = .notConfigured
        }

        if !hasOpenRouterKey {
            openRouterState = .notConfigured
        }
    }

    private func prepareRefreshState() {
        openAIState = hasOpenAIKey ? .loading(previous: openAIState.snapshot) : .notConfigured
        anthropicState = hasAnthropicKey ? .loading(previous: anthropicState.snapshot) : .notConfigured
        openRouterState = hasOpenRouterKey ? .loading(previous: openRouterState.snapshot) : .notConfigured
    }

    private func apply(_ result: Result<ProviderSnapshot, UsageError>, for provider: ProviderKind) {
        switch result {
        case let .success(snapshot):
            setState(.loaded(snapshot), for: provider)
        case let .failure(error):
            let previous = state(for: provider).snapshot
            setState(.failed(message: error.localizedDescription, previous: previous), for: provider)
        }
    }

    private func setState(_ state: ProviderLoadState, for provider: ProviderKind) {
        switch provider {
        case .openAI:
            openAIState = state
        case .anthropic:
            anthropicState = state
        case .openRouter:
            openRouterState = state
        }
    }

    private func state(for provider: ProviderKind) -> ProviderLoadState {
        switch provider {
        case .openAI:
            openAIState
        case .anthropic:
            anthropicState
        case .openRouter:
            openRouterState
        }
    }

    private func saveCredential(for provider: ProviderKind, rawValue: String) async {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else {
            settingsStatusMessage = "Enter a value before saving the \(provider.credentialTitle.lowercased())."
            return
        }

        do {
            try keychain.save(trimmedValue, for: provider)
            clearDraft(for: provider)
            settingsStatusMessage = "Saved the \(provider.credentialTitle.lowercased()) in Keychain."
            reloadCredentialStatus()
            await refreshAll()
        } catch {
            settingsStatusMessage = "Could not save the \(provider.credentialTitle.lowercased()): \(error.localizedDescription)"
        }
    }

    private func removeCredential(for provider: ProviderKind) async {
        do {
            try keychain.deleteValue(for: provider)
            clearDraft(for: provider)
            settingsStatusMessage = "Removed the \(provider.credentialTitle.lowercased()) from Keychain."
            reloadCredentialStatus()
            setState(.notConfigured, for: provider)
        } catch {
            settingsStatusMessage = "Could not remove the \(provider.credentialTitle.lowercased()): \(error.localizedDescription)"
        }
    }

    private func clearDraft(for provider: ProviderKind) {
        switch provider {
        case .openAI:
            openAIKeyDraft = ""
        case .anthropic:
            anthropicKeyDraft = ""
        case .openRouter:
            openRouterKeyDraft = ""
        }
    }
}
