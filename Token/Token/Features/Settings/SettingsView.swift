import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                Text("Token stores admin and management keys in your macOS Keychain. These reporting endpoints do not accept normal API keys: OpenAI requires an organization Admin API key, Anthropic requires an Admin API key plus an organization account, and OpenRouter requires a management key.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                CredentialEditorView(
                    provider: .openAI,
                    hasStoredCredential: model.hasOpenAIKey,
                    state: model.openAIState,
                    draft: $model.openAIKeyDraft,
                    saveAction: saveOpenAIKey,
                    removeAction: removeOpenAIKey
                )

                CredentialEditorView(
                    provider: .anthropic,
                    hasStoredCredential: model.hasAnthropicKey,
                    state: model.anthropicState,
                    draft: $model.anthropicKeyDraft,
                    saveAction: saveAnthropicKey,
                    removeAction: removeAnthropicKey
                )

                CredentialEditorView(
                    provider: .openRouter,
                    hasStoredCredential: model.hasOpenRouterKey,
                    state: model.openRouterState,
                    draft: $model.openRouterKeyDraft,
                    saveAction: saveOpenRouterKey,
                    removeAction: removeOpenRouterKey
                )

                if let settingsStatusMessage = model.settingsStatusMessage {
                    Label(settingsStatusMessage, systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .frame(minWidth: 520, minHeight: 400)
        .background(
            LinearGradient(
                colors: [
                    .clear,
                    .orange.opacity(0.04),
                    .teal.opacity(0.04),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .task {
            await model.start()
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Token")
                    .font(.title2.bold())

                Text("API Key Configuration")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Refresh", systemImage: "arrow.clockwise", action: refresh)
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(model.isRefreshing)
        }
    }

    private func refresh() {
        Task {
            await model.refreshAll()
        }
    }

    private func saveOpenAIKey() {
        Task {
            await model.saveOpenAIKey()
        }
    }

    private func removeOpenAIKey() {
        Task {
            await model.removeOpenAIKey()
        }
    }

    private func saveAnthropicKey() {
        Task {
            await model.saveAnthropicKey()
        }
    }

    private func removeAnthropicKey() {
        Task {
            await model.removeAnthropicKey()
        }
    }

    private func saveOpenRouterKey() {
        Task {
            await model.saveOpenRouterKey()
        }
    }

    private func removeOpenRouterKey() {
        Task {
            await model.removeOpenRouterKey()
        }
    }
}
