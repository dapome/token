import Foundation
import Observation

@Observable
@MainActor
final class AppModel {
    @ObservationIgnored private let keychain = KeychainStore()
    @ObservationIgnored private let openAIService = OpenAIUsageService()
    @ObservationIgnored private let anthropicService = AnthropicUsageService()
    @ObservationIgnored private let openRouterService = OpenRouterUsageService()
    @ObservationIgnored private let geminiService = GeminiUsageService()
    @ObservationIgnored private let refreshIntervalDefaultsKey = "auto_refresh_interval_seconds"

    var openAIKeyDraft = ""
    var anthropicKeyDraft = ""
    var openRouterKeyDraft = ""
    var geminiKeyDraft = ""

    private(set) var hasOpenAIKey = false
    private(set) var hasAnthropicKey = false
    private(set) var hasOpenRouterKey = false
    private(set) var hasGeminiKey = false
    private(set) var openAIState: ProviderLoadState = .notConfigured
    private(set) var anthropicState: ProviderLoadState = .notConfigured
    private(set) var openRouterState: ProviderLoadState = .notConfigured
    private(set) var geminiState: ProviderLoadState = .notConfigured
    private(set) var isRefreshing = false
    private(set) var settingsStatusMessage: String?
    var autoRefreshInterval: AutoRefreshInterval = .fifteenMinutes {
        didSet {
            UserDefaults.standard.set(autoRefreshInterval.rawValue, forKey: refreshIntervalDefaultsKey)
        }
    }

    @ObservationIgnored private var didStart = false
    @ObservationIgnored private var lastRefreshAt: Date?

    var lastUpdated: Date? {
        [openAIState.snapshot?.updatedAt, anthropicState.snapshot?.updatedAt, openRouterState.snapshot?.updatedAt, geminiState.snapshot?.updatedAt]
            .compactMap { $0 }
            .max()
    }

    var menuBarSystemImage: String {
        if isRefreshing {
            "arrow.trianglehead.2.clockwise.rotate.90"
        } else if openAIState.errorMessage != nil || anthropicState.errorMessage != nil || openRouterState.errorMessage != nil || geminiState.errorMessage != nil {
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
        loadRefreshPreference()
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
        let geminiKey = hasGeminiKey ? keychain.value(for: .gemini) : nil
        let openAIService = openAIService
        let anthropicService = anthropicService
        let openRouterService = openRouterService
        let geminiService = geminiService

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

            if let geminiKey {
                group.addTask {
                    do {
                        return (.gemini, .success(try await geminiService.fetchSnapshot(apiKey: geminiKey)))
                    } catch let error as UsageError {
                        return (.gemini, .failure(error))
                    } catch {
                        return (.gemini, .failure(.requestFailed(error.localizedDescription)))
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

    func saveGeminiKey() async {
        await saveCredential(for: .gemini, rawValue: geminiKeyDraft)
    }

    func removeGeminiKey() async {
        await removeCredential(for: .gemini)
    }

    private var shouldRefresh: Bool {
        guard autoRefreshInterval != .off else {
            return false
        }

        guard let lastRefreshAt else {
            return true
        }

        return Date.now.timeIntervalSince(lastRefreshAt) >= TimeInterval(autoRefreshInterval.rawValue)
    }

    private func loadRefreshPreference() {
        let rawValue = UserDefaults.standard.integer(forKey: refreshIntervalDefaultsKey)
        if let savedInterval = AutoRefreshInterval(rawValue: rawValue), savedInterval != .off || rawValue == 0 {
            autoRefreshInterval = savedInterval
        }
    }

    private func reloadCredentialStatus() {
        hasOpenAIKey = keychain.value(for: .openAI) != nil
        hasAnthropicKey = keychain.value(for: .anthropic) != nil
        hasOpenRouterKey = keychain.value(for: .openRouter) != nil
        hasGeminiKey = keychain.value(for: .gemini) != nil

        if !hasOpenAIKey {
            openAIState = .notConfigured
        }

        if !hasAnthropicKey {
            anthropicState = .notConfigured
        }

        if !hasOpenRouterKey {
            openRouterState = .notConfigured
        }

        if !hasGeminiKey {
            geminiState = .notConfigured
        }
    }

    private func prepareRefreshState() {
        openAIState = hasOpenAIKey ? .loading(previous: openAIState.snapshot) : .notConfigured
        anthropicState = hasAnthropicKey ? .loading(previous: anthropicState.snapshot) : .notConfigured
        openRouterState = hasOpenRouterKey ? .loading(previous: openRouterState.snapshot) : .notConfigured
        geminiState = hasGeminiKey ? .loading(previous: geminiState.snapshot) : .notConfigured
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
        case .gemini:
            geminiState = state
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
        case .gemini:
            geminiState
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
        case .gemini:
            geminiKeyDraft = ""
        }
    }
}

extension AppModel {
    enum AutoRefreshInterval: Int, CaseIterable, Identifiable {
        case off = 0
        case fiveMinutes = 300
        case fifteenMinutes = 900
        case thirtyMinutes = 1800

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .off:
                "Off"
            case .fiveMinutes:
                "5 min"
            case .fifteenMinutes:
                "15 min"
            case .thirtyMinutes:
                "30 min"
            }
        }
    }
}
