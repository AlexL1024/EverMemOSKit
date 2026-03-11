import Testing
import Foundation
@testable import EverMemOSKit

@Suite("GET /health")
struct HealthTests {
    @Test("Health check — local response format")
    func testHealthLocal() async throws {
        let tag = "health-local"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .local)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path.contains("health") == true)
            let body = TestHelper.jsonData([
                "status": "ok",
                "version": "1.0.0",
                "uptime": 12345.6,
            ] as [String: Any])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.healthCheck()
        #expect(result.status == "ok")
        #expect(result.isHealthy)
        #expect(result.version == "1.0.0")
        #expect(result.uptime == 12345.6)
        #expect(result.message == nil)
        #expect(result.service == nil)
    }

    @Test("Health check — cloud gateway response format")
    func testHealthCloud() async throws {
        let tag = "health-cloud"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .cloud)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "message": "ok",
                "service": "evermemos-gateway",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.healthCheck()
        #expect(result.message == "ok")
        #expect(result.service == "evermemos-gateway")
        #expect(result.isHealthy)
        #expect(result.status == nil)
    }

    @Test("isReachable — returns true for healthy response")
    func testIsReachableTrue() async throws {
        let tag = "health-reachable"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData(["status": "ok"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let reachable = await client.isReachable()
        #expect(reachable)
    }

    @Test("isReachable — returns false on 503")
    func testIsReachableFalse() async throws {
        let tag = "health-unreachable"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 503), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        let reachable = await client.isReachable()
        #expect(!reachable)
    }

    @Test("isReachable — returns false for non-ok message")
    func testIsReachableNonOk() async throws {
        let tag = "health-non-ok"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData(["message": "degraded"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let reachable = await client.isReachable()
        #expect(!reachable)
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
        #expect(result.isHealthy)
        #expect(result.version == nil)
        #expect(result.uptime == nil)
    }
}
