import SwiftUI

struct ProviderSectionView: View {
    let provider: ProviderKind
    let state: ProviderLoadState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: AppTheme.cardSpacing) {
                Label(provider.title, systemImage: provider.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Spacer()

                ProviderStatusBadgeView(provider: provider, state: state)
            }

            switch state {
            case .notConfigured:
                Text("No \(provider.credentialTitle.lowercased()) is stored yet.")
                    .foregroundStyle(.secondary)
                    .font(.caption)

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
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
