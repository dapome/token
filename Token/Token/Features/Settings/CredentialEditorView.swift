import SwiftUI

struct CredentialEditorView: View {
    let provider: ProviderKind
    let hasStoredCredential: Bool
    let state: ProviderLoadState
    @Binding var draft: String
    let saveAction: () -> Void
    let removeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(provider.credentialTitle, systemImage: provider.systemImage)
                    .font(.headline)

                Spacer()

                ProviderStatusBadgeView(provider: provider, state: state)
            }

            SecureField(provider.credentialPrompt, text: $draft)
                .textFieldStyle(.roundedBorder)

            Text(provider.credentialHelpText)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: AppTheme.cardSpacing) {
                Button("Save", systemImage: "key.fill", action: saveAction)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(trimmedDraft.isEmpty)

                Button("Remove", systemImage: "trash", action: removeAction)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(!hasStoredCredential)

                Spacer()

                if hasStoredCredential {
                    Label("In Keychain", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ProviderStatusView(provider: provider, state: state)

            HStack(spacing: 12) {
                Link("Usage API docs", destination: provider.usageDocsURL)
                Link("Admin key requirements", destination: provider.adminDocsURL)
            }
            .font(.caption)
        }
        .padding(AppTheme.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(provider.accentColor.opacity(0.18), lineWidth: 1)
        )
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
