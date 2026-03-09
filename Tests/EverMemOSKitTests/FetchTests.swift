import Testing
import Foundation
@testable import EverMemOSKit

@Suite("GET /api/v0/memories")
struct FetchTests {
    @Test("Success — fetch episodic memories")
    func testFetchSuccess() async throws {
        let tag = "fetch-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            let body = TestHelper.jsonData([
                "status": "ok",
                "message": "ok",
                "result": [
                    "memories": [
                        ["memory_type": "episodic_memory", "summary": "Test memory"]
                    ],
                    "total_count": 1,
                    "count": 1,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = FetchMemoriesBuilder()
        builder.userId = "user_001"
        let result = try await client.fetchMemories(builder)
        #expect(result.totalCount == 1)
        #expect(result.memories.count == 1)
    }

    @Test("Failure — API error")
    func testFetchFailure() async throws {
        let tag = "fetch-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = FetchMemoriesBuilder()
        builder.userId = "user_001"
        await #expect(throws: EverMemOSError.self) {
            try await client.fetchMemories(builder)
        }
    }

    @Test("Decode compat — empty memories")
    func testFetchDecodeCompat() async throws {
        let tag = "fetch-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": ["total_count": 0, "count": 0] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = FetchMemoriesBuilder()
        builder.userId = "u1"
        let result = try await client.fetchMemories(builder)
        #expect(result.memories.isEmpty)
        #expect(result.totalCount == 0)
    }
}
