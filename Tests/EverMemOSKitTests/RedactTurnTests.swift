import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Redact Turn")
struct RedactTurnTests {
    @Test("Redact success")
    func testRedactSuccess() async throws {
        let tag = "redact-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "DELETE")
            #expect(request.url?.path.contains("turns") == true)
            let body = TestHelper.jsonData([
                "redacted": true, "turn_id": "t_001",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.redactTurn("t_001")
        #expect(result.redacted == true)
        #expect(result.turnId == "t_001")
    }

    @Test("Redact failure")
    func testRedactFailure() async throws {
        let tag = "redact-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 404), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.redactTurn("missing")
        }
    }

    @Test("Redact decode compat")
    func testRedactDecodeCompat() async throws {
        let tag = "redact-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "redacted": false, "turn_id": "t_x",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.redactTurn("t_x")
        #expect(result.redacted == false)
    }
}
