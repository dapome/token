import SwiftUI

struct TokenSummaryTileView: View {
    let title: String
    let inputTokens: Int
    let outputTokens: Int
    let systemImage: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                TokenValueView(
                    title: "In",
                    value: inputTokens.formatted(.number.notation(.compactName)),
                    systemImage: "arrow.down.left.circle.fill"
                )
                Spacer()
                TokenValueView(
                    title: "Out",
                    value: outputTokens.formatted(.number.notation(.compactName)),
                    systemImage: "arrow.up.right.circle.fill"
                )
            }
        }
        .frame(maxWidth: .infinity, minHeight: AppTheme.tileMinimumHeight, alignment: .leading)
        .padding(10)
        .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: AppTheme.tileCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.tileCornerRadius)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct TokenValueView: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: systemImage)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .bold()
                .monospacedDigit()
        }
    }
}
