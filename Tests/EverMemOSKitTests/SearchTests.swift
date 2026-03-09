import Testing
import Foundation
@testable import EverMemOSKit

@Suite("GET /api/v1/memories/search")
struct SearchTests {
    @Test("Success — with scores and groups")
    func testSearchSuccess() async throws {
        let tag = "search-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "memories": [
                        ["group_123": [
                            ["memory_type": "episodic_memory", "summary": "Test"]
                        ]]
                    ],
                    "scores": [["group_123": [0.95]]],
                    "importance_scores": [0.85],
                    "original_data": [] as [Any],
                    "total_count": 1,
                    "has_more": false,
                    "pending_messages": [] as [Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = SearchMemoriesBuilder()
        builder.userId = "user_001"
        builder.query = "test"
        let result = try await client.searchMemories(builder)
        #expect(result.totalCount == 1)
        #expect(result.scores.count == 1)
        #expect(result.importanceScores == [0.85])
    }

    @Test("Failure — API error")
    func testSearchFailure() async throws {
        let tag = "search-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = SearchMemoriesBuilder()
        builder.userId = "u1"
        await #expect(throws: EverMemOSError.self) {
            try await client.searchMemories(builder)
        }
    }

    @Test("Decode compat — empty groups")
    func testSearchDecodeCompat() async throws {
        let tag = "search-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "total_count": 0,
                    "has_more": false,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = SearchMemoriesBuilder()
        builder.userId = "u1"
        let result = try await client.searchMemories(builder)
        #expect(result.memories.isEmpty)
        #expect(result.pendingMessages.isEmpty)
    }
}
