import SwiftUI

struct MenuBarRootView: View {
    @Bindable var model: AppModel

    private var configuredProviders: [(ProviderKind, ProviderLoadState)] {
        allProviders.filter { $0.1 != .notConfigured }
    }

    private var unconfiguredProviders: [(ProviderKind, ProviderLoadState)] {
        allProviders.filter { $0.1 == .notConfigured }
    }

    private var allProviders: [(ProviderKind, ProviderLoadState)] {
        [
            (.openAI, model.openAIState),
            (.anthropic, model.anthropicState),
            (.openRouter, model.openRouterState),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                header
                quickLinks

                ForEach(configuredProviders, id: \.0) { provider, state in
                    ProviderSectionView(provider: provider, state: state)
                }

                if !unconfiguredProviders.isEmpty {
                    unconfiguredSection
                }
            }
            .padding(AppTheme.contentPadding)
        }
        .frame(minWidth: AppTheme.menuWidth, minHeight: AppTheme.menuMinHeight)
        .background(
            LinearGradient(
                colors: [
                    .clear,
                    .orange.opacity(0.06),
                    .teal.opacity(0.05),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .task {
            await model.start()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("Token")
                .font(.headline)

            Spacer()

            if let lastUpdated = model.lastUpdated {
                Text(lastUpdated.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: refresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .disabled(model.isRefreshing)
            .help("Refresh all providers")

            SettingsLink {
                Image(systemName: "gearshape")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Open settings")
        }
    }

    private var unconfiguredSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(unconfiguredProviders, id: \.0) { provider, _ in
                HStack {
                    Label(provider.title, systemImage: provider.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("Not configured")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, AppTheme.cardPadding)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(.secondary.opacity(0.12), lineWidth: 1)
        )
    }

    private var quickLinks: some View {
        HStack(spacing: 16) {
            ForEach(ProviderKind.subscriptionCases) { provider in
                Link(destination: provider.subscriptionURL) {
                    Label(provider.subscriptionTitle, systemImage: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    private func refresh() {
        Task {
            await model.refreshAll()
        }
    }
}
