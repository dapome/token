import SwiftUI

struct ProviderStatusBadgeView: View {
    let provider: ProviderKind
    let state: ProviderLoadState

    private var title: String {
        switch state {
        case .notConfigured:
            "Needs Key"
        case .loading:
            "Refreshing"
        case .loaded:
            "Connected"
        case .failed:
            "Attention"
        }
    }

    private var systemImage: String {
        switch state {
        case .notConfigured:
            "key.slash.fill"
        case .loading:
            "arrow.clockwise"
        case .loaded:
            "checkmark.circle.fill"
        case .failed:
            "exclamationmark.triangle.fill"
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .notConfigured:
            .secondary.opacity(0.16)
        case .loading:
            provider.secondaryAccentColor.opacity(0.2)
        case .loaded:
            provider.accentColor.opacity(0.18)
        case .failed:
            .orange.opacity(0.2)
        }
    }

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor, in: Capsule())
    }
}
