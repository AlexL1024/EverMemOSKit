import Foundation

/// Protocol for authentication providers.
public protocol AuthProvider: Sendable {
    func applyAuth(to request: inout URLRequest) async
}
