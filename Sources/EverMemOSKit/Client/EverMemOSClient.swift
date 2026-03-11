import Foundation

/// Main entry point for the EverMemOS API.
public actor EverMemOSClient {
    private let transport: HTTPTransport
    private let v: String
    private let statusPath: String

    public init(config: Configuration) {
        self.transport = HTTPTransport(config: config)
        self.v = config.apiVersion
        self.statusPath = config.statusPathSegment
    }

    /// Convenience: create a client with bearer token auth.
    public init(
        baseURL: URL,
        token: String,
        apiVersion: String = "v0",
        timeoutInterval: TimeInterval = 30,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0,
        logLevel: Configuration.LogLevel = .error
    ) {
        let config = Configuration(
            baseURL: baseURL,
            auth: BearerTokenAuth(token: token),
            apiVersion: apiVersion,
            timeoutInterval: timeoutInterval,
            maxRetries: maxRetries,
            retryDelay: retryDelay,
            logLevel: logLevel
        )
        self.transport = HTTPTransport(config: config)
        self.v = config.apiVersion
        self.statusPath = config.statusPathSegment
    }

    /// For testing: inject a custom URLSession.
    public init(config: Configuration, session: URLSession) {
        self.transport = HTTPTransport(config: config, session: session)
        self.v = config.apiVersion
        self.statusPath = config.statusPathSegment
    }

    // MARK: - Memories

    public func memorize(_ request: MemorizeRequest) async throws -> AddMemoriesResponse {
        try await transport.requestBare(
            method: "POST", path: "api/\(v)/memories", body: request
        )
    }

    public func fetchMemories(_ builder: FetchMemoriesBuilder) async throws -> FetchMemoriesResult {
        try await transport.requestBaseAPI(
            method: "GET", path: "api/\(v)/memories", query: builder.build()
        )
    }

    public func searchMemories(_ builder: SearchMemoriesBuilder) async throws -> SearchResponse {
        try await transport.requestBaseAPI(
            method: "GET", path: "api/\(v)/memories/search", query: builder.build()
        )
    }

    public func deleteMemories(_ request: DeleteMemoriesRequest) async throws -> DeleteMemoriesResult {
        if request.memoryId == nil,
           request.id == nil,
           request.eventId == nil,
           request.userId == nil,
           request.groupId == nil {
            throw EverMemOSError.invalidParameter("At least one filter must be provided for deleteMemories.")
        }
        return try await transport.requestBaseAPI(
            method: "DELETE", path: "api/\(v)/memories", body: request
        )
    }

    // MARK: - Conversation Meta

    public func createConversationMeta(
        _ request: ConversationMetaCreateRequest
    ) async throws -> ConversationMetaData {
        try await transport.requestBaseAPI(
            method: "POST", path: "api/\(v)/memories/conversation-meta", body: request
        )
    }

    public func getConversationMeta(
        groupId: String? = nil
    ) async throws -> ConversationMetaData {
        var query: [String: String] = [:]
        if let gid = groupId { query["group_id"] = gid }
        return try await transport.requestBaseAPI(
            method: "GET", path: "api/\(v)/memories/conversation-meta", query: query
        )
    }

    public func patchConversationMeta(
        _ request: ConversationMetaPatchRequest
    ) async throws -> PatchConversationMetaResult {
        try await transport.requestBaseAPI(
            method: "PATCH", path: "api/\(v)/memories/conversation-meta", body: request
        )
    }

    // MARK: - Profile

    public func upsertCustomProfile(
        _ request: UpsertCustomProfileRequest
    ) async throws -> SuccessResponse<[String: AnyCodableValue]> {
        try await transport.requestSuccess(
            method: "POST", path: "api/\(v)/global-user-profile/custom", body: request
        )
    }

    // MARK: - Status & Health

    public func getRequestStatus(
        requestId: String
    ) async throws -> SuccessResponse<RequestStatusData> {
        try await transport.requestSuccess(
            method: "GET",
            path: "api/\(v)/\(statusPath)/request",
            query: ["request_id": requestId]
        )
    }

    public func healthCheck() async throws -> HealthResponse {
        try await transport.requestBare(method: "GET", path: "health")
    }

    /// Returns true if the server responds to /health with a healthy status.
    public func isReachable() async -> Bool {
        do {
            let response = try await healthCheck()
            return response.isHealthy
        } catch {
            return false
        }
    }

}
