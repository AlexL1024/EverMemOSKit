import Foundation

// MARK: - Search Response (full fields per P1-3)

public struct SearchResponse: Decodable, Sendable {
    public let memories: [FlexibleMemory]
    public let profiles: [SearchProfile]
    public let scores: [[String: [Double]]]
    public let importanceScores: [Double]
    public let originalData: [[String: [[String: AnyCodableValue]]]]
    public let totalCount: Int
    public let hasMore: Bool
    public let queryMetadata: [String: AnyCodableValue]?
    public let metadata: [String: AnyCodableValue]?
    public let pendingMessages: [PendingMessage]

    enum CodingKeys: String, CodingKey {
        case memories, scores, profiles
        case importanceScores = "importance_scores"
        case originalData = "original_data"
        case totalCount = "total_count"
        case hasMore = "has_more"
        case queryMetadata = "query_metadata"
        case metadata
        case pendingMessages = "pending_messages"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.memories = try c.decodeIfPresent([FlexibleMemory].self, forKey: .memories) ?? []
        self.profiles = try c.decodeIfPresent([SearchProfile].self, forKey: .profiles) ?? []
        self.scores = try c.decodeIfPresent([[String: [Double]]].self, forKey: .scores) ?? []
        self.importanceScores = try c.decodeIfPresent([Double].self, forKey: .importanceScores) ?? []
        self.originalData = try c.decodeIfPresent([[String: [[String: AnyCodableValue]]]].self, forKey: .originalData) ?? []
        self.totalCount = try c.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        self.hasMore = try c.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        self.queryMetadata = try c.decodeIfPresent([String: AnyCodableValue].self, forKey: .queryMetadata)
        self.metadata = try c.decodeIfPresent([String: AnyCodableValue].self, forKey: .metadata)
        self.pendingMessages = try c.decodeIfPresent([PendingMessage].self, forKey: .pendingMessages) ?? []
    }
}

// MARK: - PendingMessage

public struct PendingMessage: Decodable, Sendable {
    public let id: String?
    public let requestId: String?
    public let messageId: String?
    public let groupId: String?
    public let userId: String?
    public let sender: String?
    public let senderName: String?
    public let groupName: String?
    public let content: String?
    public let referList: [String]?
    public let messageCreateTime: String?
    public let createdAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case requestId = "request_id"
        case messageId = "message_id"
        case groupId = "group_id"
        case userId = "user_id"
        case sender
        case senderName = "sender_name"
        case groupName = "group_name"
        case content
        case referList = "refer_list"
        case messageCreateTime = "message_create_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - SearchProfile

public struct SearchProfile: Decodable, Sendable {
    public let itemType: String?
    public let category: String?
    public let traitName: String?
    public let description: String?
    public let score: Double?

    enum CodingKeys: String, CodingKey {
        case itemType = "item_type"
        case category
        case traitName = "trait_name"
        case description
        case score
    }
}
