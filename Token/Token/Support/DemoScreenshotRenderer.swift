import AppKit
import SwiftUI

@MainActor
enum DemoScreenshotRenderer {
    static func outputURL(arguments: [String] = CommandLine.arguments) -> URL? {
        guard let flagIndex = arguments.firstIndex(of: "--render-demo-screenshot"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return nil
        }

        let outputPath = arguments[arguments.index(after: flagIndex)]
        if outputPath.hasPrefix("/") {
            return URL(fileURLWithPath: outputPath)
        }

        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(outputPath)
            .standardizedFileURL
    }

    static func render(to outputURL: URL) throws {
        let size = CGSize(width: AppTheme.menuWidth, height: AppTheme.menuMinHeight)
        let hostingView = NSHostingView(
            rootView: TokenDemoScreenshotView()
                .environment(\.colorScheme, .dark)
                .frame(width: size.width, height: size.height)
        )
        hostingView.frame = CGRect(origin: .zero, size: size)
        hostingView.appearance = NSAppearance(named: .darkAqua)
        hostingView.layoutSubtreeIfNeeded()

        guard let bitmap = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
            throw RenderError.bitmapCreationFailed
        }

        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)

        guard let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else {
            throw RenderError.imageEncodingFailed
        }

        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: outputURL, options: .atomic)
    }
}

extension DemoScreenshotRenderer {
    enum RenderError: LocalizedError {
        case bitmapCreationFailed
        case imageEncodingFailed

        var errorDescription: String? {
            switch self {
            case .bitmapCreationFailed:
                "Could not create a bitmap for the demo screenshot."
            case .imageEncodingFailed:
                "Could not encode the demo screenshot."
            }
        }
    }
}
