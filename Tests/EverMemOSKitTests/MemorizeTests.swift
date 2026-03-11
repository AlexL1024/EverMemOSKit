import Testing
import Foundation
@testable import EverMemOSKit

@Suite("POST /api/{v}/memories (Add Memories)")
struct MemorizeTests {
    @Test("Success — queued response")
    func testMemorizeQueued() async throws {
        let tag = "memorize-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url?.path.contains("memories") == true)
            let body = TestHelper.jsonData([
                "status": "queued",
                "message": "Memories added successfully. request_id: req_test_001",
                "request_id": "req_test_001",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = MemorizeRequest(
            messageId: "msg_001", createTime: "2025-01-15T10:00:00+00:00",
            sender: "user_001", content: "Hello world"
        )
        let result = try await client.memorize(req)
        #expect(result.status == "queued")
        #expect(result.requestId == "req_test_001")
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
}
