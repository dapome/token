import SwiftUI

struct ProviderSnapshotView: View {
    let provider: ProviderKind
    let snapshot: ProviderSnapshot

    var body: some View {
        VStack(spacing: 4) {
            metricRow(
                label: "Month Spend",
                value: UsageFormatting.currency(snapshot.costMonth)
            )

            if let requests = snapshot.monthRequests {
                metricRow(
                    label: "Requests",
                    value: UsageFormatting.requestCount(requests)
                )
            }

            detailRows
        }
    }

    @ViewBuilder
    private var detailRows: some View {
        if snapshot.hasTokenBreakdown,
           let todayIn = snapshot.todayInputTokens,
           let todayOut = snapshot.todayOutputTokens,
           let monthIn = snapshot.monthInputTokens,
           let monthOut = snapshot.monthOutputTokens {
            tokenRow(label: "Today", input: todayIn, output: todayOut)
            tokenRow(label: "Month", input: monthIn, output: monthOut)
        } else {
            if let costToday = snapshot.costToday {
                metricRow(
                    label: "Today",
                    value: UsageFormatting.currency(costToday)
                )
            }

            if let remainingCredits = snapshot.remainingCredits {
                metricRow(
                    label: "Credits Left",
                    value: UsageFormatting.currency(remainingCredits)
                )
            } else if let totalUsage = snapshot.totalUsage {
                metricRow(
                    label: "Total Used",
                    value: UsageFormatting.currency(totalUsage)
                )
            }
        }
    }

    private func metricRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }

    private func tokenRow(label: String, input: Int, output: Int) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 12) {
                Label(
                    input.formatted(.number.notation(.compactName)),
                    systemImage: "arrow.down.left"
                )

                Label(
                    output.formatted(.number.notation(.compactName)),
                    systemImage: "arrow.up.right"
                )
            }
            .font(.caption)
            .fontWeight(.medium)
            .monospacedDigit()
        }
    }
}
