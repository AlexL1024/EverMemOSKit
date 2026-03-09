import Testing
import Foundation
@testable import EverMemOSKit

@Suite("GET /health")
struct HealthTests {
    @Test("Health check success")
    func testHealthSuccess() async throws {
        let tag = "health-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path.contains("health") == true)
            let body = TestHelper.jsonData([
                "status": "healthy",
                "version": "1.0.0",
                "uptime": 12345.6,
            ] as [String: Any])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.healthCheck()
        #expect(result.status == "healthy")
        #expect(result.version == "1.0.0")
    }

    @Test("Health check failure")
    func testHealthFailure() async throws {
        let tag = "health-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 503), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.healthCheck()
        }
    }

    @Test("Health decode compat — minimal fields")
    func testHealthDecodeCompat() async throws {
        let tag = "health-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData(["status": "ok"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.healthCheck()
        #expect(result.status == "ok")
        #expect(result.version == nil)
        #expect(result.uptime == nil)
    }
}
