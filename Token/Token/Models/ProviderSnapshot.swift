import Foundation

struct ProviderSnapshot: Equatable, Sendable {
    let costMonth: Decimal
    let costToday: Decimal?
    let totalCredits: Decimal?
    let totalUsage: Decimal?
    let todayInputTokens: Int?
    let todayOutputTokens: Int?
    let todayRequests: Int?
    let monthInputTokens: Int?
    let monthOutputTokens: Int?
    let monthRequests: Int?
    let updatedAt: Date
    let note: String?

    var hasTokenBreakdown: Bool {
        todayInputTokens != nil
            && todayOutputTokens != nil
            && monthInputTokens != nil
            && monthOutputTokens != nil
    }

    var remainingCredits: Decimal? {
        guard let totalCredits, let totalUsage else {
            return nil
        }

        return totalCredits - totalUsage
    }
}
