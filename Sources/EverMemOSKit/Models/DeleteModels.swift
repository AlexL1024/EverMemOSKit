import Foundation

// MARK: - DELETE /api/{v}/memories

public struct DeleteMemoriesRequest: Encodable, Sendable {
    /// Memory ID.
    public let memoryId: String?
    /// Alias of `memory_id`.
    public let id: String?
    /// Event ID.
    public let eventId: String?
    /// User ID.
    public let userId: String?
    /// Group ID.
    public let groupId: String?

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

    enum CodingKeys: String, CodingKey {
        case memoryId = "memory_id"
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case groupId = "group_id"
    }
}

/// Server returns {filters: [str], count: int} — NOT {deleted_count}
public struct DeleteMemoriesResult: Decodable, Sendable {
    public let filters: [String]
    public let count: Int

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.filters = try c.decodeIfPresent([String].self, forKey: .filters) ?? []
        self.count = try c.decodeIfPresent(Int.self, forKey: .count) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case filters, count
    }
}
