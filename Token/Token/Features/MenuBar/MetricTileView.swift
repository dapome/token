import SwiftUI

struct MetricTileView: View {
    let title: String
    let value: String
    let systemImage: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .bold()
                .monospacedDigit()
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
