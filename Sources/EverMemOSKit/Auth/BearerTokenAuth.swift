import Foundation

/// Bearer token authentication.
public struct BearerTokenAuth: AuthProvider {
    private let token: String

    public init(token: String) {
        self.token = token
    }

    public func applyAuth(to request: inout URLRequest) async {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
