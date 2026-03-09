import Foundation

// MARK: - POST /api/v1/memories

public struct MemorizeRequest: Encodable, Sendable {
    public let messageId: String
    public let createTime: String
    public let sender: String
    public let content: String
    public var groupId: String?
    public var groupName: String?
    public var senderName: String?
    public var role: String?
    public var referList: [String]?
    public var flush: Bool?

    public init(
        messageId: String,
        createTime: String,
        sender: String,
        content: String,
        groupId: String? = nil,
        groupName: String? = nil,
        senderName: String? = nil,
        role: String? = nil,
        referList: [String]? = nil,
        flush: Bool? = nil
    ) {
        self.messageId = messageId
        self.createTime = createTime
        self.sender = sender
        self.content = content
        self.groupId = groupId
        self.groupName = groupName
        self.senderName = senderName
        self.role = role
        self.referList = referList
        self.flush = flush
    }

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case createTime = "create_time"
        case sender, content
        case groupId = "group_id"
        case groupName = "group_name"
        case senderName = "sender_name"
        case role
        case referList = "refer_list"
        case flush
    }
}

public struct MemorizeResult: Decodable, Sendable {
    public let savedMemories: [AnyCodableValue]?
    public let count: Int
    public let statusInfo: String

    enum CodingKeys: String, CodingKey {
        case savedMemories = "saved_memories"
        case count
        case statusInfo = "status_info"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.savedMemories = try container.decodeIfPresent([AnyCodableValue].self, forKey: .savedMemories)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.statusInfo = try container.decodeIfPresent(String.self, forKey: .statusInfo) ?? "accumulated"
    }
}
