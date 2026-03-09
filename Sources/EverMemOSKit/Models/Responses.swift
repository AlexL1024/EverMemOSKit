import Foundation

// MARK: - Pattern 1: BaseAPIResponse — memories, conversation-meta, chat/export

public struct BaseAPIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let status: String
    public let message: String
    public let result: T?
}

// MARK: - Pattern 2: SuccessResponse — status, global-user-profile

public struct SuccessResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let success: Bool
    public let found: Bool?
    public let data: T?
    public let message: String?
}
