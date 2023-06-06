import Foundation

enum AuthenticationStatus {
    case authenticated
    case unauthenticated
    case inProgress
    case error
    case none

    var message: String {
        switch self {
        case .authenticated:
            return "User is authenticated."
        case .unauthenticated:
            return "User is not authenticated."
        case .inProgress:
            return "Authentication is in progress."
        case .error:
            return "An error occurred during authentication."
        case .none:
            return "Use TouchId to authentication"
        }
    }
}
