import Foundation
import SwiftUI

@main
struct TokenApp: App {
    @State private var model = AppModel()

    init() {
        if let outputURL = DemoScreenshotRenderer.outputURL() {
            do {
                try DemoScreenshotRenderer.render(to: outputURL)
                Foundation.exit(EXIT_SUCCESS)
            } catch {
                fputs("Could not render demo screenshot: \(error.localizedDescription)\n", stderr)
                Foundation.exit(EXIT_FAILURE)
            }
        }
    }

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
