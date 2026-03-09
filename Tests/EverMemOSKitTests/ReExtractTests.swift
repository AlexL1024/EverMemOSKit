import Testing
import Foundation
@testable import EverMemOSKit

@Suite("POST /api/v1/chat/re-extract")
struct ReExtractTests {
    @Test("Re-extract success")
    func testReExtractSuccess() async throws {
        let tag = "reextract-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            let body = TestHelper.jsonData([
                "queued_count": 3,
                "user_id": "user_001",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ReExtractRequest(userId: "user_001")
        let result = try await client.reExtract(req)
        #expect(result.queuedCount == 3)
        #expect(result.userId == "user_001")
    }

    @Test("Re-extract failure")
    func testReExtractFailure() async throws {
        let tag = "reextract-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ReExtractRequest(userId: "u1")
        await #expect(throws: EverMemOSError.self) {
            try await client.reExtract(req)
        }
    }

    @Test("Re-extract decode compat")
    func testReExtractDecodeCompat() async throws {
        let tag = "reextract-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "queued_count": 0,
                "user_id": "u1",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ReExtractRequest(userId: "u1")
        let result = try await client.reExtract(req)
        #expect(result.queuedCount == 0)
    }
}
