import SwiftUI

struct DashboardHeroView: View {
    let lastUpdated: Date?
    let providerStates: [ProviderLoadState]
    let isRefreshing: Bool

    private var connectedCount: Int {
        providerStates.reduce(into: 0) { partialResult, state in
            if case .loaded = state {
                partialResult += 1
            }
        }
    }

    private var issueCount: Int {
        providerStates.reduce(into: 0) { partialResult, state in
            if state.errorMessage != nil {
                partialResult += 1
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            .orange.opacity(0.78),
                            .pink.opacity(0.42),
                            .blue.opacity(0.52),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.15))
                .frame(width: 104, height: 104)
                .offset(x: 22, y: -20)

            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 64, height: 64)
                .offset(x: -10, y: 34)

            HStack(alignment: .top, spacing: AppTheme.sectionSpacing) {
                VStack(alignment: .leading, spacing: AppTheme.rowSpacing) {
                    Text("Token")
                        .font(.title3)
                        .bold()

                    Text("API totals up front, subscription usage one tap away.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))

                    HStack(spacing: 8) {
                        SummaryChipView(
                            title: "\(connectedCount) live",
                            systemImage: connectedCount > 0 ? "bolt.fill" : "bolt.slash.fill"
                        )

                        SummaryChipView(
                            title: issueCount == 0 ? "Stable" : "\(issueCount) attention",
                            systemImage: issueCount == 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                        )

                        if let lastUpdated {
                            SummaryChipView(
                                title: lastUpdated.formatted(date: .omitted, time: .shortened),
                                systemImage: "clock.fill"
                            )
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: isRefreshing ? "arrow.trianglehead.2.clockwise.rotate.90" : "chart.line.text.clipboard")
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(AppTheme.heroPadding)
            .foregroundStyle(.white)
        }
        .accessibilityElement(children: .combine)
    }
}
