import SwiftUI

struct ProviderStatusBadgeView: View {
    let provider: ProviderKind
    let state: ProviderLoadState

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

    private var tintColor: Color {
        switch state {
        case .notConfigured:
            .secondary
        case .loading:
            .secondary
        case .loaded:
            .secondary
        case .failed:
            .orange
        }
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tintColor)
            .help(accessibilityTitle)
    }

    private var accessibilityTitle: String {
        switch state {
        case .notConfigured:
            "\(provider.title) needs a key"
        case .loading:
            "\(provider.title) refreshing"
        case .loaded:
            "\(provider.title) connected"
        case .failed:
            "\(provider.title) needs attention"
        }
    }
}
