import Foundation

// MARK: - POST /api/{v}/memories (Add Memories)

public struct MemorizeRequest: Encodable, Sendable {
    public let messageId: String
    public let createTime: String
    public var sender: String
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

public struct AddMemoriesResponse: Decodable, Sendable {
    /// Present in non-flush responses (e.g. "ok", "queued").
    public let status: String?
    /// Human-readable message from the server.
    public let message: String?
    /// Present in flush/async responses (HTTP 202).
    public let requestId: String?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case requestId = "request_id"
    }
}

public typealias MemorizeResponse = AddMemoriesResponse
