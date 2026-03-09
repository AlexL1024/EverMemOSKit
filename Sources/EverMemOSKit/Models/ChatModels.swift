import Foundation

// MARK: - POST /api/v1/chat/stream Request

public struct ChatStreamRequest: Encodable, Sendable {
    public let userId: String
    public let sessionId: String
    public let messageId: String
    public let message: String
    public var locale: String
    public var timezone: String
    public var clientTime: String?

    public init(
        userId: String,
        sessionId: String,
        messageId: String,
        message: String,
        locale: String = "zh-CN",
        timezone: String = "Asia/Shanghai",
        clientTime: String? = nil
    ) {
        self.userId = userId
        self.sessionId = sessionId
        self.messageId = messageId
        self.message = message
        self.locale = locale
        self.timezone = timezone
        self.clientTime = clientTime
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sessionId = "session_id"
        case messageId = "message_id"
        case message, locale, timezone
        case clientTime = "client_time"
    }
}

// MARK: - SSE Data Payload

public struct ChatSSEData: Decodable, Sendable {
    public let type: String
    public let content: String?
    public let citations: [[String: AnyCodableValue]]?
    public let error: String?

    public var eventType: ChatSSEEventType {
        ChatSSEEventType(rawValue: type) ?? .error
    }
}

// MARK: - Pattern 3: Bare object responses

public struct DeleteSessionResult: Decodable, Sendable {
    public let deletedCount: Int
    public let sessionId: String

    enum CodingKeys: String, CodingKey {
        case deletedCount = "deleted_count"
        case sessionId = "session_id"
    }
}

public struct RedactTurnResult: Decodable, Sendable {
    public let redacted: Bool
    public let turnId: String

    enum CodingKeys: String, CodingKey {
        case redacted
        case turnId = "turn_id"
    }
}

// MARK: - Re-extract

public struct ReExtractRequest: Encodable, Sendable {
    public let userId: String
    public var sessionId: String?
    public var startTime: String?
    public var endTime: String?

    public init(
        userId: String,
        sessionId: String? = nil,
        startTime: String? = nil,
        endTime: String? = nil
    ) {
        self.userId = userId
        self.sessionId = sessionId
        self.startTime = startTime
        self.endTime = endTime
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sessionId = "session_id"
        case startTime = "start_time"
        case endTime = "end_time"
    }
}

public struct ReExtractResult: Decodable, Sendable {
    public let queuedCount: Int
    public let userId: String

    enum CodingKeys: String, CodingKey {
        case queuedCount = "queued_count"
        case userId = "user_id"
    }
}

// MARK: - Session Export

public struct SessionExportItem: Decodable, Sendable {
    public let turnId: String
    public let role: String
    public let content: String
    public let clientTime: String?
    public let serverTime: String

    enum CodingKeys: String, CodingKey {
        case turnId = "turn_id"
        case role, content
        case clientTime = "client_time"
        case serverTime = "server_time"
    }
}

public struct SessionExportResponse: Decodable, Sendable {
    public let sessionId: String
    public let turns: [SessionExportItem]
    public let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case turns
        case totalCount = "total_count"
    }
}
