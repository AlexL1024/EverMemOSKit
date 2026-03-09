import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Chat Session Management")
struct ChatSessionTests {
    // MARK: - Delete Session

    @Test("Delete session success")
    func testDeleteSessionSuccess() async throws {
        let tag = "chatsession-delete-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "DELETE")
            #expect(request.url?.path.contains("sessions") == true)
            let body = TestHelper.jsonData([
                "deleted_count": 5,
                "session_id": "sess_001",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.deleteSession("sess_001")
        #expect(result.deletedCount == 5)
        #expect(result.sessionId == "sess_001")
    }

    @Test("Delete session failure")
    func testDeleteSessionFailure() async throws {
        let tag = "chatsession-delete-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 404), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.deleteSession("missing")
        }
    }

    @Test("Delete session decode compat")
    func testDeleteSessionDecodeCompat() async throws {
        let tag = "chatsession-delete-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "deleted_count": 0,
                "session_id": "s1",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.deleteSession("s1")
        #expect(result.deletedCount == 0)
    }
}
