import Foundation

/// Main entry point for the EverMemOS API.
public actor EverMemOSClient {
    private let transport: HTTPTransport
    private let v: String

    public init(config: Configuration) {
        self.transport = HTTPTransport(config: config)
        self.v = config.apiVersion
    }

    /// For testing: inject a custom URLSession.
    public init(config: Configuration, session: URLSession) {
        self.transport = HTTPTransport(config: config, session: session)
        self.v = config.apiVersion
    }

    // MARK: - 1. POST /api/{v}/memories

    public func memorize(_ request: MemorizeRequest) async throws -> MemorizeResult {
        try await transport.requestBaseAPI(
            method: "POST", path: "api/\(v)/memories", body: request
        )
    }

    // MARK: - 2. GET /api/{v}/memories (query params)

    public func fetchMemories(_ builder: FetchMemoriesBuilder) async throws -> FetchMemoriesResult {
        try await transport.requestBaseAPI(
            method: "GET", path: "api/\(v)/memories", query: builder.build()
        )
    }

    // MARK: - 3. GET /api/{v}/memories/search

    public func searchMemories(_ builder: SearchMemoriesBuilder) async throws -> SearchResponse {
        try await transport.requestBaseAPI(
            method: "GET", path: "api/\(v)/memories/search", query: builder.build()
        )
    }

    // MARK: - 4. DELETE /api/{v}/memories

    public func deleteMemories(_ request: DeleteMemoriesRequest) async throws -> DeleteMemoriesResult {
        try await transport.requestBaseAPI(
            method: "DELETE", path: "api/\(v)/memories", body: request
        )
    }

    // MARK: - 5. POST /api/{v}/chat/stream (SSE)

    public func chatStream(
        _ request: ChatStreamRequest,
        deepSeekAPIKey: String? = nil
    ) -> AsyncThrowingStream<ChatSSEData, Error> {
        var headers: [String: String] = [:]
        if let key = deepSeekAPIKey, !key.isEmpty {
            headers["X-DeepSeek-API-Key"] = key
        }
        return transport.streamSSE(
            path: "api/\(v)/chat/stream", body: request, extraHeaders: headers
        )
    }

    // MARK: - 6. DELETE /api/{v}/chat/sessions/{id}

    public func deleteSession(_ sessionId: String, deletedBy: String = "caregiver") async throws -> DeleteSessionResult {
        try await transport.requestBare(
            method: "DELETE",
            path: "api/\(v)/chat/sessions/\(sessionId)",
            query: ["deleted_by": deletedBy]
        )
    }

    // MARK: - 7. DELETE /api/{v}/chat/turns/{id}

    public func redactTurn(_ turnId: String) async throws -> RedactTurnResult {
        try await transport.requestBare(
            method: "DELETE", path: "api/\(v)/chat/turns/\(turnId)"
        )
    }

    // MARK: - 8. GET /api/{v}/chat/sessions/{id}/export

    public func exportSession(_ sessionId: String) async throws -> SessionExportResponse {
        try await transport.requestBare(
            method: "GET", path: "api/\(v)/chat/sessions/\(sessionId)/export"
        )
    }

    // MARK: - 9. POST /api/{v}/chat/re-extract

    public func reExtract(_ request: ReExtractRequest) async throws -> ReExtractResult {
        try await transport.requestBare(
            method: "POST", path: "api/\(v)/chat/re-extract", body: request
        )
    }

    // MARK: - 10. POST /api/{v}/memories/conversation-meta

    public func createConversationMeta(
        _ request: ConversationMetaCreateRequest
    ) async throws -> ConversationMetaData {
        try await transport.requestBaseAPI(
            method: "POST", path: "api/\(v)/memories/conversation-meta", body: request
        )
    }

    // MARK: - 11. GET /api/{v}/memories/conversation-meta

    public func getConversationMeta(
        groupId: String? = nil
    ) async throws -> ConversationMetaData {
        var query: [String: String] = [:]
        if let gid = groupId { query["group_id"] = gid }
        return try await transport.requestBaseAPI(
            method: "GET", path: "api/\(v)/memories/conversation-meta", query: query
        )
    }

    // MARK: - 12. PATCH /api/{v}/memories/conversation-meta

    public func patchConversationMeta(
        _ request: ConversationMetaPatchRequest
    ) async throws -> PatchConversationMetaResult {
        try await transport.requestBaseAPI(
            method: "PATCH", path: "api/\(v)/memories/conversation-meta", body: request
        )
    }

    // MARK: - 13. POST /api/{v}/global-user-profile/custom

    public func upsertCustomProfile(
        _ request: UpsertCustomProfileRequest
    ) async throws -> SuccessResponse<[String: AnyCodableValue]> {
        try await transport.requestSuccess(
            method: "POST", path: "api/\(v)/global-user-profile/custom", body: request
        )
    }

    // MARK: - 14. GET /health

    public func healthCheck() async throws -> HealthResponse {
        try await transport.requestBare(method: "GET", path: "health")
    }
}