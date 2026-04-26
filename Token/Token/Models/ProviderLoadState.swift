import Foundation

enum ProviderLoadState: Equatable {
    case notConfigured
    case loading(previous: ProviderSnapshot?)
    case loaded(ProviderSnapshot)
    case failed(message: String, previous: ProviderSnapshot?)

    var snapshot: ProviderSnapshot? {
        switch self {
        case .notConfigured:
            nil
        case let .loading(previous):
            previous
        case let .loaded(snapshot):
            snapshot
        case let .failed(_, previous):
            previous
        }
    }

    var errorMessage: String? {
        switch self {
        case .failed(let message, _):
            message
        case .notConfigured, .loading, .loaded:
            nil
        }
    }
}
