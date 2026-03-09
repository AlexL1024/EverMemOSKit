import Foundation

// MARK: - GET /api/v0/memories (query params)

public struct FetchMemoriesBuilder: Sendable {
    public var userId: String?
    public var groupIds: [String] = []
    public var memoryType: MemoryType = .episodicMemory
    public var page: Int = 1
    public var pageSize: Int = 20
    public var startTime: String?
    public var endTime: String?

    public init() {}

    /// Convenience: set a single groupId (wraps into array).
    public mutating func setGroupId(_ id: String) {
        groupIds = [id]
    }

    /// Build query parameters for GET request (iOS URLSession rejects GET+body).
    public func build() -> [String: String] {
        var params: [String: String] = [:]
        if let uid = userId { params["user_id"] = uid }
        if !groupIds.isEmpty { params["group_ids"] = groupIds.joined(separator: ",") }
        params["memory_type"] = memoryType.rawValue
        params["page"] = "\(page)"
        params["page_size"] = "\(pageSize)"
        if let st = startTime { params["start_time"] = st }
        if let et = endTime { params["end_time"] = et }
        return params
    }
}

/// Encodable request body — kept for unit tests verifying field names.
public struct FetchMemoriesRequestBody: Encodable, Sendable {
    public let userId: String?
    public let groupIds: [String]?
    public let memoryType: String
    public let page: Int
    public let pageSize: Int
    public let startTime: String?
    public let endTime: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case groupIds = "group_ids"
        case memoryType = "memory_type"
        case page
        case pageSize = "page_size"
        case startTime = "start_time"
        case endTime = "end_time"
    }

    public init(from builder: FetchMemoriesBuilder) {
        self.userId = builder.userId
        self.groupIds = builder.groupIds.isEmpty ? nil : builder.groupIds
        self.memoryType = builder.memoryType.rawValue
        self.page = builder.page
        self.pageSize = builder.pageSize
        self.startTime = builder.startTime
        self.endTime = builder.endTime
    }
}

public struct FetchMemoriesResult: Decodable, Sendable {
    public let memories: [FlexibleMemory]
    public let totalCount: Int
    public let count: Int
    public let metadata: [String: AnyCodableValue]?

    enum CodingKeys: String, CodingKey {
        case memories
        case totalCount = "total_count"
        case count
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.memories = try container.decodeIfPresent([FlexibleMemory].self, forKey: .memories) ?? []
        self.totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        self.count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.metadata = try container.decodeIfPresent([String: AnyCodableValue].self, forKey: .metadata)
    }
}
