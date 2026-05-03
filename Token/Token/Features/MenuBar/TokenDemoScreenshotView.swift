import Foundation
import SwiftUI

struct TokenDemoScreenshotView: View {
    private let lastUpdated = Date(timeIntervalSince1970: 1_798_900_260)

    private var providers: [(ProviderKind, ProviderLoadState)] {
        [
            (.openAI, .loaded(.demoOpenAI(updatedAt: lastUpdated))),
            (.anthropic, .loaded(.demoAnthropic(updatedAt: lastUpdated))),
            (.openRouter, .loaded(.demoOpenRouter(updatedAt: lastUpdated))),
            (.gemini, .loaded(.demoGemini(updatedAt: lastUpdated))),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                header
                quickLinks
                Divider()

                ForEach(providers, id: \.0) { provider, state in
                    ProviderSectionView(provider: provider, state: state)
                    Divider()
                }
            }
            .padding(10)
        }
        .frame(width: AppTheme.menuWidth)
        .frame(minHeight: AppTheme.menuMinHeight)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("Token")
                .font(.headline)

            Spacer()

            Text(lastUpdated.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: "arrow.clockwise")
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: "gearshape")
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: "power")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var quickLinks: some View {
        HStack(spacing: 16) {
            ForEach(ProviderKind.subscriptionCases) { provider in
                Label(provider.subscriptionTitle, systemImage: "arrow.up.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Label("Cursor", systemImage: "arrow.up.right")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

private extension ProviderSnapshot {
    static func demoOpenAI(updatedAt: Date) -> ProviderSnapshot {
        ProviderSnapshot(
            costMonth: 12.48,
            costToday: nil,
            totalCredits: nil,
            totalUsage: nil,
            todayInputTokens: 84_200,
            todayOutputTokens: 6_400,
            todayRequests: 128,
            monthInputTokens: 1_840_000,
            monthOutputTokens: 142_000,
            monthRequests: 2_418,
            updatedAt: updatedAt,
            note: "Demo data"
        )
    }

    static func demoAnthropic(updatedAt: Date) -> ProviderSnapshot {
        ProviderSnapshot(
            costMonth: 8.73,
            costToday: nil,
            totalCredits: nil,
            totalUsage: nil,
            todayInputTokens: 42_100,
            todayOutputTokens: 3_200,
            todayRequests: nil,
            monthInputTokens: 912_000,
            monthOutputTokens: 78_000,
            monthRequests: nil,
            updatedAt: updatedAt,
            note: "Demo data"
        )
    }

    static func demoOpenRouter(updatedAt: Date) -> ProviderSnapshot {
        ProviderSnapshot(
            costMonth: 1.92,
            costToday: 0.14,
            totalCredits: 25.00,
            totalUsage: 7.35,
            todayInputTokens: nil,
            todayOutputTokens: nil,
            todayRequests: nil,
            monthInputTokens: nil,
            monthOutputTokens: nil,
            monthRequests: nil,
            updatedAt: updatedAt,
            note: "Demo data"
        )
    }

    static func demoGemini(updatedAt: Date) -> ProviderSnapshot {
        ProviderSnapshot(
            costMonth: .zero,
            costToday: nil,
            totalCredits: nil,
            totalUsage: nil,
            todayInputTokens: nil,
            todayOutputTokens: nil,
            todayRequests: nil,
            monthInputTokens: nil,
            monthOutputTokens: nil,
            monthRequests: nil,
            updatedAt: updatedAt,
            note: "Demo data"
        )
    }
}
