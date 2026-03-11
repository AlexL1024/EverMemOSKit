import Foundation

// MARK: - GET /api/{v}/memories

public struct FetchMemoriesBuilder: Sendable {
    public var userId: String?
    public var groupIds: [String] = []
    /// Page number (1-indexed).
    public var page: Int = 1
    /// Page size (1...100).
    public var pageSize: Int = 20
    public var memoryType: MemoryType = .episodicMemory
    public var startTime: String?
    public var endTime: String?

    public init() {}

    public func build() -> [String: String] {
        var params: [String: String] = [
            "page": String(page),
            "page_size": String(pageSize),
            "memory_type": memoryType.rawValue,
        ]
        if let v = userId { params["user_id"] = v }
        if !groupIds.isEmpty {
            params["group_ids"] = QueryEncoding.jsonArrayString(groupIds)
        }
        if let v = startTime { params["start_time"] = v }
        if let v = endTime { params["end_time"] = v }
        return params
    }
}

public struct FetchMemoriesResult: Decodable, Sendable {
    public let count: Int
    public let memories: [FlexibleMemory]
    public let metadata: [String: AnyCodableValue]?
    public let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case count
        case memories
        case metadata
        case totalCount = "total_count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
        self.memories = try container.decodeIfPresent([FlexibleMemory].self, forKey: .memories) ?? []
        self.metadata = try container.decodeIfPresent([String: AnyCodableValue].self, forKey: .metadata)
        self.totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
    }
}
