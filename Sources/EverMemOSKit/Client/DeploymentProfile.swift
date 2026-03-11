import Foundation

/// Deployment profile for EverMemOS — cloud vs local.
public enum DeploymentProfile: String, Sendable, CaseIterable {
    case cloud
    case local

    /// Default base URL for this deployment profile.
    public var defaultBaseURL: URL {
        switch self {
        case .cloud: URL(string: "https://api.evermind.ai")!
        case .local: URL(string: "http://localhost:1995")!
        }
    }

    /// API version path segment.
    public var apiVersion: String {
        switch self {
        case .cloud: "v0"
        case .local: "v1"
        }
    }

    /// Path segment for status/stats endpoints.
    public var statusPathSegment: String {
        switch self {
        case .cloud: "status"
        case .local: "stats"
        }
    }

    /// Whether this profile requires authentication.
    public var requiresAuth: Bool {
        switch self {
        case .cloud: true
        case .local: false
        }
    }
}
