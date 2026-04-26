import SwiftUI

struct SubscriptionNoticeSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.rowSpacing) {
            HStack {
                Label("Quick Links", systemImage: "link.circle.fill")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("Subscription usage")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: AppTheme.rowSpacing) {
                ForEach(ProviderKind.subscriptionCases) { provider in
                    SubscriptionLinkCardView(provider: provider)
                }
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}
