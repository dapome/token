import SwiftUI

@main
struct TokenApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView(model: model)
        } label: {
            Image(systemName: model.menuBarSystemImage)
                .accessibilityLabel(model.menuBarAccessibilityLabel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(model: model)
        }
    }
}
