import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Session Export")
struct ExportTests {
    @Test("Export success")
    func testExportSuccess() async throws {
        let tag = "export-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            let body = TestHelper.jsonData([
                "session_id": "sess_001",
                "turns": [
                    [
                        "turn_id": "t1", "role": "user",
                        "content": "Hello",
                        "server_time": "2025-01-15T10:00:00Z",
                    ]
                ],
                "total_count": 1,
            ] as [String: Any])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.exportSession("sess_001")
        #expect(result.sessionId == "sess_001")
        #expect(result.turns.count == 1)
        #expect(result.totalCount == 1)
    }

    @Test("Export failure")
    func testExportFailure() async throws {
        let tag = "export-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 404), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.exportSession("missing")
        }
    }

    @Test("Export decode compat — empty turns")
    func testExportDecodeCompat() async throws {
        let tag = "export-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "session_id": "s1",
                "turns": [] as [Any],
                "total_count": 0,
            ] as [String: Any])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.exportSession("s1")
        #expect(result.turns.isEmpty)
    }
}
