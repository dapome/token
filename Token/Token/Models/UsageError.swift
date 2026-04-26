import Foundation

enum UsageError: LocalizedError, Sendable {
    case unauthorized(String)
    case accessUnavailable(String)
    case invalidConfiguration(String)
    case invalidResponse
    case invalidPayload
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case let .unauthorized(message):
            message
        case let .accessUnavailable(message):
            message
        case let .invalidConfiguration(message):
            message
        case .invalidResponse:
            "The provider returned an invalid response."
        case .invalidPayload:
            "The provider returned data in an unexpected format."
        case let .requestFailed(message):
            message
        }
    }
}
