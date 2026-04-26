import SwiftUI

struct SubscriptionLinkCardView: View {
    let provider: ProviderKind

    var body: some View {
        Link(destination: provider.subscriptionURL) {
            HStack(spacing: 10) {
                Image(systemName: provider.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(provider.accentColor)
                    .frame(width: 28, height: 28)
                    .background(provider.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)

                Text(provider.subscriptionTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(provider.accentColor.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(provider.accentColor.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open \(provider.subscriptionTitle) usage page")
    }
}
