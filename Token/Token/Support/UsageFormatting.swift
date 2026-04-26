import Foundation

enum UsageFormatting {
    nonisolated static func currency(_ amount: Decimal) -> String {
        amount.formatted(.currency(code: "USD").precision(.fractionLength(2)))
    }

    nonisolated static func tokenPair(input: Int, output: Int) -> String {
        "\(abbreviatedNumber(input)) in / \(abbreviatedNumber(output)) out"
    }

    nonisolated static func requestCount(_ count: Int) -> String {
        count.formatted(.number.grouping(.automatic))
    }

    nonisolated private static func abbreviatedNumber(_ value: Int) -> String {
        value.formatted(.number.notation(.compactName))
    }
}
