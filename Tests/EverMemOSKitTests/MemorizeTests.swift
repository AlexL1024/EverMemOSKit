import Testing
import Foundation
@testable import EverMemOSKit

@Suite("POST /api/v1/memories")
struct MemorizeTests {
    @Test("Success — extracted memories")
    func testMemorizeSuccess() async throws {
        let tag = "memorize-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path.contains("memories") == true)
            let body = TestHelper.jsonData([
                "status": "ok",
                "message": "Extracted 1 memories",
                "result": [
                    "saved_memories": [] as [Any],
                    "count": 1,
                    "status_info": "extracted",
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = MemorizeRequest(
            messageId: "msg_001", createTime: "2025-01-15T10:00:00+00:00",
            sender: "user_001", content: "Hello world"
        )
        let result = try await client.memorize(req)
        #expect(result.count == 1)
        #expect(result.statusInfo == "extracted")
    }

    @Test("Failure — API error")
    func testMemorizeFailure() async throws {
        let tag = "memorize-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData(["detail": "Validation error"])
            return (TestHelper.errorResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = MemorizeRequest(
            messageId: "msg_001", createTime: "2025-01-15T10:00:00+00:00",
            sender: "user_001", content: "Hello"
        )
        await #expect(throws: EverMemOSError.self) {
            try await client.memorize(req)
        }
    }

    @Test("Decode compat — missing optional fields")
    func testMemorizeDecodeCompat() async throws {
        let tag = "memorize-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok",
                "message": "ok",
                "result": ["count": 0, "status_info": "accumulated"] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = MemorizeRequest(
            messageId: "m1", createTime: "2025-01-01T00:00:00Z",
            sender: "u1", content: "test"
        )
        let result = try await client.memorize(req)
        #expect(result.count == 0)
        #expect(result.savedMemories == nil)
    }
}
