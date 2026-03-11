import Foundation

/// No-op authentication provider for local deployments that require no auth.
public struct NoAuth: AuthProvider {
    public init() {}

    public func applyAuth(to request: inout URLRequest) async {
        // No authentication needed
    }
}
