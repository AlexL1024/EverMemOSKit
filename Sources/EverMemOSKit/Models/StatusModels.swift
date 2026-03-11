import Foundation

// MARK: - GET /health

public struct HealthResponse: Decodable, Sendable {
    /// Local returns "status", cloud gateway returns "message"
    public let status: String?
    public let message: String?
    public let service: String?
    public let version: String?
    public let uptime: Double?

    /// True if the response indicates a healthy server.
    public var isHealthy: Bool {
        if let s = status { return s.lowercased() == "ok" }
        if let m = message { return m.lowercased() == "ok" }
        return false
    }
}
