import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel

    var body: some View {
        ScrollView {
            HStack {
                Text("API Key Configuration")
                    .font(.headline)
                Spacer()
                Button("Refresh", systemImage: "arrow.clockwise", action: refresh)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(model.isRefreshing)
            }
            .padding(.bottom, 8)

            Text("Keys are saved in your macOS Keychain. Use admin/management keys for reporting APIs.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text("Auto-refresh")
                    .font(.subheadline)
                Spacer()
                Picker("Auto-refresh", selection: $model.autoRefreshInterval) {
                    ForEach(AppModel.AutoRefreshInterval.allCases) { interval in
                        Text(interval.title).tag(interval)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }
            .padding(.top, 6)

            Divider()
                .padding(.vertical, 4)

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

            CredentialEditorView(
                provider: .gemini,
                hasStoredCredential: model.hasGeminiKey,
                state: model.geminiState,
                draft: $model.geminiKeyDraft,
                saveAction: saveGeminiKey,
                removeAction: removeGeminiKey
            )

            if let settingsStatusMessage = model.settingsStatusMessage {
                Text(settingsStatusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .frame(minWidth: 420, minHeight: 440)
        .task {
            await model.start()
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

    private func saveGeminiKey() {
        Task {
            await model.saveGeminiKey()
        }
    }

    private func removeGeminiKey() {
        Task {
            await model.removeGeminiKey()
        }
    }
}
