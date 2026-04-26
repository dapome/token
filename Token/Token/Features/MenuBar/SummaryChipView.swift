import SwiftUI

struct SummaryChipView: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.14), in: Capsule())
    }
}
