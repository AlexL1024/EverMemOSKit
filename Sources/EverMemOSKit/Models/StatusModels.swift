import Foundation

// MARK: - GET /health

public struct HealthResponse: Decodable, Sendable {
    public let status: String
    public let version: String?
    public let uptime: Double?
}
