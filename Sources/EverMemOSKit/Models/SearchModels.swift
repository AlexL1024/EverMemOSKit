import Foundation

// MARK: - FlexibleMemory — union of all memory type fields

public struct FlexibleMemory: Decodable, Sendable {
    // Common
    public let memoryType: String?
    public let userId: String?
    public let timestamp: String?
    public let groupId: String?
    public let groupName: String?
    public let keywords: [String]?
    public let linkedEntities: [String]?
    public let id: String?
    // Episode
    public let summary: String?
    public let episode: String?
    public let subject: String?
    // EventLog
    public let atomicFact: String?
    public let parentType: String?
    public let parentId: String?
    // Foresight
    public let foresight: String?
    public let evidence: String?
    public let startTime: String?
    public let endTime: String?
    public let durationDays: Int?
    // Profile
    public let content: String?

    enum CodingKeys: String, CodingKey {
        case memoryType = "memory_type"
        case userId = "user_id"
        case timestamp
        case groupId = "group_id"
        case groupName = "group_name"
        case keywords
        case linkedEntities = "linked_entities"
        case id
        case summary, episode, subject
        case atomicFact = "atomic_fact"
        case parentType = "parent_type"
        case parentId = "parent_id"
        case foresight, evidence
        case startTime = "start_time"
        case endTime = "end_time"
        case durationDays = "duration_days"
        case content
    }
}

// MARK: - Search Request Builder

public struct SearchMemoriesBuilder: Sendable {
    public var userId: String?
    public var groupId: String?
    public var query: String?
    public var memoryTypes: [MemoryType] = []
    public var retrieveMethod: RetrieveMethod = .keyword
    public var topK: Int = 40
    public var includeMetadata: Bool = true
    public var startTime: String?
    public var endTime: String?
    public var currentTime: String?
    public var radius: Double?

    public init() {}

    public func build() -> [String: String] {
        var params: [String: String] = [
            "top_k": String(topK),
            "retrieve_method": retrieveMethod.rawValue,
            "include_metadata": String(includeMetadata),
        ]
        if let v = userId { params["user_id"] = v }
        if let v = groupId { params["group_id"] = v }
        if let v = query { params["query"] = v }
        if !memoryTypes.isEmpty {
            params["memory_types"] = memoryTypes.map(\.rawValue).joined(separator: ",")
        }
        if let v = startTime { params["start_time"] = v }
        if let v = endTime { params["end_time"] = v }
        if let v = currentTime { params["current_time"] = v }
        if let v = radius { params["radius"] = String(v) }
        return params
    }
}
