import Testing
import Foundation
@testable import EverMemOSKit

@Suite("DELETE /api/v1/memories")
struct DeleteTests {
    @Test("Success — filters + count response")
    func testDeleteSuccess() async throws {
        let tag = "delete-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "DELETE")
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "filters": ["user_id", "group_id"],
                    "count": 10,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = DeleteMemoriesRequest(userId: "user_001", groupId: "group_001")
        let result = try await client.deleteMemories(req)
        #expect(result.filters == ["user_id", "group_id"])
        #expect(result.count == 10)
    }

    @Test("Failure — API error")
    func testDeleteFailure() async throws {
        let tag = "delete-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = DeleteMemoriesRequest(userId: "u1")
        await #expect(throws: EverMemOSError.self) {
            try await client.deleteMemories(req)
        }
    }

    @Test("Decode compat — missing optional fields")
    func testDeleteDecodeCompat() async throws {
        let tag = "delete-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [:] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = DeleteMemoriesRequest(userId: "u1")
        let result = try await client.deleteMemories(req)
        #expect(result.filters.isEmpty)
        #expect(result.count == 0)
    }
}
