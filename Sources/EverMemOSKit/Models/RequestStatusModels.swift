import Foundation

// MARK: - GET /api/{v}/status/request

public struct RequestStatusData: Decodable, Sendable {
    public let requestId: String
    public let status: String
    public let progress: RequestProgress

    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case status
        case progress
    }
}

public struct RequestProgress: Decodable, Sendable {
    public let total: Int
    public let completed: Int
    public let failed: Int
    public let errors: [AnyCodableValue]

    enum CodingKeys: String, CodingKey {
        case total, completed, failed, errors
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.total = try c.decodeIfPresent(Int.self, forKey: .total) ?? 0
        self.completed = try c.decodeIfPresent(Int.self, forKey: .completed) ?? 0
        self.failed = try c.decodeIfPresent(Int.self, forKey: .failed) ?? 0
        self.errors = try c.decodeIfPresent([AnyCodableValue].self, forKey: .errors) ?? []
    }
}

