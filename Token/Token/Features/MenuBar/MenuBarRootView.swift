import SwiftUI
import AppKit

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
            (.gemini, model.geminiState),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                header
                quickLinks
                Divider()

                ForEach(configuredProviders, id: \.0) { provider, state in
                    ProviderSectionView(provider: provider, state: state)
                    Divider()
                }

                if !unconfiguredProviders.isEmpty {
                    unconfiguredSection
                }
            }
            .padding(10)
        }
        .frame(minWidth: AppTheme.menuWidth, minHeight: AppTheme.menuMinHeight)
        .background(Color(nsColor: .windowBackgroundColor))
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

            Button(action: quitApp) {
                Image(systemName: "power")
                    .font(.caption)
            }
            .buttonStyle(.borderless)
            .help("Quit Token")
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
        .padding(.top, 2)
    }

    private var quickLinks: some View {
        HStack(spacing: 16) {
            ForEach(ProviderKind.subscriptionCases) { provider in
                Link(destination: provider.subscriptionURL) {
                    Label(provider.subscriptionTitle, systemImage: "arrow.up.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            Link(destination: AppLinks.cursorUsage) {
                Label("Cursor", systemImage: "arrow.up.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    private func refresh() {
        Task {
            await model.refreshAll()
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
