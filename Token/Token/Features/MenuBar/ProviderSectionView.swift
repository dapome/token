import SwiftUI

struct ProviderSectionView: View {
    let provider: ProviderKind
    let state: ProviderLoadState

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.cardSpacing) {
            HStack(spacing: AppTheme.cardSpacing) {
                Label(provider.title, systemImage: provider.systemImage)
                    .font(.headline)

                Spacer()

                ProviderStatusBadgeView(provider: provider, state: state)
            }

            switch state {
            case .notConfigured:
                Text("No \(provider.credentialTitle.lowercased()) is stored yet.")
                    .foregroundStyle(.secondary)

            case .loading(let previous):
                if let previous {
                    ProviderSnapshotView(provider: provider, snapshot: previous)
                } else {
                    ProgressView("Loading \(provider.title.lowercased())…")
                        .controlSize(.small)
                }

            case .loaded(let snapshot):
                ProviderSnapshotView(provider: provider, snapshot: snapshot)

            case let .failed(message, previous):
                if let previous {
                    ProviderSnapshotView(provider: provider, snapshot: previous)
                }

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(provider.accentColor.opacity(0.18), lineWidth: 1)
        )
    }
}
