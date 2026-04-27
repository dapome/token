import SwiftUI

struct ProviderStatusView: View {
    let provider: ProviderKind
    let state: ProviderLoadState

    var body: some View {
        HStack(spacing: 8) {
            statusContent

            Spacer()
        }
        .font(.caption)
    }

    @ViewBuilder
    private var statusContent: some View {
        switch state {
        case .notConfigured:
            Label("No key saved yet", systemImage: "key.slash.fill")
                .foregroundStyle(.secondary)

        case .loading:
            ProgressView()
                .controlSize(.small)
            Text("Checking \(provider.title.lowercased())…")
                .foregroundStyle(.secondary)

        case .loaded:
            Label("Connected and reporting", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.secondary)

        case let .failed(message, _):
            VStack(alignment: .leading, spacing: 4) {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Link("How to get the right key", destination: provider.adminDocsURL)
            }
        }
    }
}
