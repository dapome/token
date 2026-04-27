import SwiftUI

struct CredentialEditorView: View {
    let provider: ProviderKind
    let hasStoredCredential: Bool
    let state: ProviderLoadState
    @Binding var draft: String
    let saveAction: () -> Void
    let removeAction: () -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                SecureField(provider.credentialPrompt, text: $draft)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)

                Text(provider.credentialHelpText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Button("Save", action: saveAction)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .disabled(trimmedDraft.isEmpty)

                    Button("Remove", action: removeAction)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(!hasStoredCredential)

                    if hasStoredCredential {
                        Text("Saved")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                ProviderStatusView(provider: provider, state: state)

                HStack(spacing: 10) {
                    Link("Usage docs", destination: provider.usageDocsURL)
                    Link("Admin docs", destination: provider.adminDocsURL)
                }
                .font(.caption)
            }
        }
        label: {
            Label(provider.title, systemImage: provider.systemImage)
                .font(.subheadline.weight(.semibold))
        }
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
