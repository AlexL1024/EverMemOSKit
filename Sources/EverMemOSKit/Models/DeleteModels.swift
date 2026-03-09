import Foundation

// MARK: - DELETE /api/v0/memories

public struct DeleteMemoriesRequest: Encodable, Sendable {
    public let memoryId: String?
    public let id: String?
    public let eventId: String?
    public let userId: String?
    public let groupId: String?

    /// At least one of memoryId, userId, or groupId must be provided.
    public init(
        memoryId: String? = nil,
        id: String? = nil,
        eventId: String? = nil,
        userId: String? = nil,
        groupId: String? = nil
    ) {
        self.memoryId = memoryId
        self.id = id
        self.eventId = eventId
        self.userId = userId
        self.groupId = groupId
    }

    /// Convenience: delete all memories (empty body per API docs).
    public static var deleteAll: DeleteMemoriesRequest {
        DeleteMemoriesRequest()
    }

    enum CodingKeys: String, CodingKey {
        case memoryId = "memory_id"
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case groupId = "group_id"
    }

    /// Only encode non-nil fields so deleteAll produces `{}`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let v = memoryId { try container.encode(v, forKey: .memoryId) }
        if let v = id { try container.encode(v, forKey: .id) }
        if let v = eventId { try container.encode(v, forKey: .eventId) }
        if let v = userId { try container.encode(v, forKey: .userId) }
        if let v = groupId { try container.encode(v, forKey: .groupId) }
    }
}

/// Server returns {filters: [str], count: int} in `result`,
/// or {message: "...N records affected"} when result is null.
public struct DeleteMemoriesResult: Decodable, Sendable {
    public let filters: [String]
    public let count: Int

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.filters = try c.decodeIfPresent([String].self, forKey: .filters) ?? []
        if let count = try c.decodeIfPresent(Int.self, forKey: .count), count > 0 {
            self.count = count
        } else if let message = try c.decodeIfPresent(String.self, forKey: .message) {
            self.count = Self.parseCount(from: message)
        } else {
            self.count = 0
        }
    }

    enum CodingKeys: String, CodingKey {
        case filters, count, message
    }

    /// Extract count from messages like "Delete operation completed, 639 records affected"
    private static func parseCount(from message: String) -> Int {
        guard let match = message.range(of: #"\d+ records? affected"#, options: .regularExpression) else { return 0 }
        let segment = message[match]
        guard let numEnd = segment.firstIndex(of: " ") else { return 0 }
        return Int(segment[segment.startIndex..<numEnd]) ?? 0
    }
}
