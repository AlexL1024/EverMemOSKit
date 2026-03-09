import Foundation

// MARK: - POST /api/v1/memories/conversation-meta

public struct ConversationMetaCreateRequest: Encodable, Sendable {
    public let scene: String
    public let sceneDesc: [String: AnyCodableValue]
    public let name: String
    public let createdAt: String
    public var description: String?
    public var groupId: String?
    public var defaultTimezone: String?
    public var userDetails: [String: UserDetail]?
    public var tags: [String]?

    public init(
        scene: String,
        sceneDesc: [String: AnyCodableValue],
        name: String,
        createdAt: String,
        description: String? = nil,
        groupId: String? = nil,
        defaultTimezone: String? = nil,
        userDetails: [String: UserDetail]? = nil,
        tags: [String]? = nil
    ) {
        self.scene = scene
        self.sceneDesc = sceneDesc
        self.name = name
        self.createdAt = createdAt
        self.description = description
        self.groupId = groupId
        self.defaultTimezone = defaultTimezone
        self.userDetails = userDetails
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case scene
        case sceneDesc = "scene_desc"
        case name
        case createdAt = "created_at"
        case description
        case groupId = "group_id"
        case defaultTimezone = "default_timezone"
        case userDetails = "user_details"
        case tags
    }
}

// MARK: - UserDetail

public struct UserDetail: Codable, Sendable {
    public let fullName: String?
    public let role: String?
    public let customRole: String?
    public let extra: [String: AnyCodableValue]?

    public init(
        fullName: String? = nil,
        role: String? = nil,
        customRole: String? = nil,
        extra: [String: AnyCodableValue]? = nil
    ) {
        self.fullName = fullName
        self.role = role
        self.customRole = customRole
        self.extra = extra
    }

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case role
        case customRole = "custom_role"
        case extra
    }
}

// MARK: - GET Response

public struct ConversationMetaData: Decodable, Sendable {
    public let id: String
    public let groupId: String?
    public let scene: String
    public let sceneDesc: [String: AnyCodableValue]?
    public let name: String
    public let description: String?
    public let conversationCreatedAt: String?
    public let defaultTimezone: String?
    public let userDetails: [String: [String: AnyCodableValue]]
    public let tags: [String]
    public let isDefault: Bool
    public let createdAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, scene, name, description, tags
        case groupId = "group_id"
        case sceneDesc = "scene_desc"
        case conversationCreatedAt = "conversation_created_at"
        case defaultTimezone = "default_timezone"
        case userDetails = "user_details"
        case isDefault = "is_default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.groupId = try c.decodeIfPresent(String.self, forKey: .groupId)
        self.scene = try c.decode(String.self, forKey: .scene)
        self.sceneDesc = try c.decodeIfPresent([String: AnyCodableValue].self, forKey: .sceneDesc)
        self.name = try c.decode(String.self, forKey: .name)
        self.description = try c.decodeIfPresent(String.self, forKey: .description)
        self.conversationCreatedAt = try c.decodeIfPresent(String.self, forKey: .conversationCreatedAt)
        self.defaultTimezone = try c.decodeIfPresent(String.self, forKey: .defaultTimezone)
        self.userDetails = try c.decodeIfPresent([String: [String: AnyCodableValue]].self, forKey: .userDetails) ?? [:]
        self.tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        self.isDefault = try c.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
        self.createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}

// MARK: - PATCH Request

public struct ConversationMetaPatchRequest: Encodable, Sendable {
    public var groupId: String?
    public var name: String?
    public var description: String?
    public var sceneDesc: [String: AnyCodableValue]?
    public var tags: [String]?
    public var userDetails: [String: UserDetail]?
    public var defaultTimezone: String?

    public init(
        groupId: String? = nil,
        name: String? = nil,
        description: String? = nil,
        sceneDesc: [String: AnyCodableValue]? = nil,
        tags: [String]? = nil,
        userDetails: [String: UserDetail]? = nil,
        defaultTimezone: String? = nil
    ) {
        self.groupId = groupId
        self.name = name
        self.description = description
        self.sceneDesc = sceneDesc
        self.tags = tags
        self.userDetails = userDetails
        self.defaultTimezone = defaultTimezone
    }

    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case name, description, tags
        case sceneDesc = "scene_desc"
        case userDetails = "user_details"
        case defaultTimezone = "default_timezone"
    }
}

// MARK: - PATCH Result

public struct PatchConversationMetaResult: Decodable, Sendable {
    public let id: String
    public let groupId: String?
    public let scene: String?
    public let name: String?
    public let updatedFields: [String]
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, scene, name
        case groupId = "group_id"
        case updatedFields = "updated_fields"
        case updatedAt = "updated_at"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.groupId = try c.decodeIfPresent(String.self, forKey: .groupId)
        self.scene = try c.decodeIfPresent(String.self, forKey: .scene)
        self.name = try c.decodeIfPresent(String.self, forKey: .name)
        self.updatedFields = try c.decodeIfPresent([String].self, forKey: .updatedFields) ?? []
        self.updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}
