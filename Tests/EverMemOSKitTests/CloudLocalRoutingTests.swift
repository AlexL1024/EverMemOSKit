import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Cloud vs Local API routing")
struct CloudLocalRoutingTests {

    // MARK: - API Version in Paths

    @Test("Cloud client uses /api/v0/ prefix")
    func testCloudApiVersion() async throws {
        let tag = "route-cloud-v0"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .cloud)
        MockURLProtocol.register(tag) { request in
            #expect(request.url!.path.contains("/api/v0/"))
            let body = TestHelper.jsonData([
                "status": "success",
                "message": "ok",
                "result": [
                    "count": 0,
                    "memories": [] as [Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = FetchMemoriesBuilder()
        builder.userId = "u1"
        _ = try await client.fetchMemories(builder)
    }

    @Test("Local client uses /api/v1/ prefix")
    func testLocalApiVersion() async throws {
        let tag = "route-local-v1"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .local)
        MockURLProtocol.register(tag) { request in
            #expect(request.url!.path.contains("/api/v1/"))
            let body = TestHelper.jsonData([
                "status": "success",
                "message": "ok",
                "result": [
                    "count": 0,
                    "memories": [] as [Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = FetchMemoriesBuilder()
        builder.userId = "u1"
        _ = try await client.fetchMemories(builder)
    }

    // MARK: - Status Path Segment

    @Test("Cloud client uses /status/request")
    func testCloudStatusPath() async throws {
        let tag = "route-cloud-status"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .cloud)
        MockURLProtocol.register(tag) { request in
            #expect(request.url!.path.contains("/api/v0/status/request"))
            let body = TestHelper.jsonData([
                "success": true,
                "found": true,
                "data": [
                    "request_id": "r1",
                    "status": "completed",
                    "progress": [
                        "total": 1, "completed": 1, "failed": 0, "errors": [] as [Any],
                    ] as [String: Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let response = try await client.getRequestStatus(requestId: "r1")
        #expect(response.success == true)
    }

    @Test("Local client uses /stats/request")
    func testLocalStatsPath() async throws {
        let tag = "route-local-stats"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .local)
        MockURLProtocol.register(tag) { request in
            #expect(request.url!.path.contains("/api/v1/stats/request"))
            let body = TestHelper.jsonData([
                "success": true,
                "found": true,
                "data": [
                    "request_id": "r2",
                    "status": "completed",
                    "progress": [
                        "total": 1, "completed": 1, "failed": 0, "errors": [] as [Any],
                    ] as [String: Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let response = try await client.getRequestStatus(requestId: "r2")
        #expect(response.success == true)
    }

    // MARK: - Auth Headers

    @Test("Cloud client sends Authorization header")
    func testCloudSendsAuth() async throws {
        let tag = "route-cloud-auth"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .cloud)
        MockURLProtocol.register(tag) { request in
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
            let body = TestHelper.jsonData(["status": "ok"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        _ = try await client.healthCheck()
    }

    @Test("Local client sends no auth headers")
    func testLocalNoAuth() async throws {
        let tag = "route-local-noauth"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .local)
        MockURLProtocol.register(tag) { request in
            #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
            let body = TestHelper.jsonData(["status": "ok"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        _ = try await client.healthCheck()
    }

    // MARK: - Memorize Works on Both

    @Test("Memorize on cloud uses /api/v0/memories")
    func testMemorizeCloud() async throws {
        let tag = "route-memorize-cloud"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .cloud)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url!.path.contains("/api/v0/memories"))
            let body = TestHelper.jsonData([
                "status": "queued",
                "message": "Processing",
                "request_id": "req_001",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = MemorizeRequest(
            messageId: "m1", createTime: "2026-01-01T00:00:00Z",
            sender: "user", content: "hello"
        )
        let result = try await client.memorize(req)
        #expect(result.requestId == "req_001")
    }

    @Test("Memorize on local uses /api/v1/memories")
    func testMemorizeLocal() async throws {
        let tag = "route-memorize-local"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .local)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            #expect(request.url!.path.contains("/api/v1/memories"))
            let body = TestHelper.jsonData([
                "status": "queued",
                "message": "Processing",
                "request_id": "req_002",
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = MemorizeRequest(
            messageId: "m2", createTime: "2026-01-01T00:00:00Z",
            sender: "user", content: "hello"
        )
        let result = try await client.memorize(req)
        #expect(result.requestId == "req_002")
    }

    // MARK: - Search Works on Both

    @Test("Search on cloud uses /api/v0/memories/search")
    func testSearchCloud() async throws {
        let tag = "route-search-cloud"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .cloud)
        MockURLProtocol.register(tag) { request in
            #expect(request.url!.path.contains("/api/v0/memories/search"))
            let body = TestHelper.jsonData([
                "status": "success",
                "message": "ok",
                "result": [
                    "memories": [] as [Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = SearchMemoriesBuilder()
        builder.userId = "u1"
        builder.query = "test"
        _ = try await client.searchMemories(builder)
    }

    @Test("Search on local uses /api/v1/memories/search")
    func testSearchLocal() async throws {
        let tag = "route-search-local"
        let (client, _) = TestHelper.makeClient(tag: tag, profile: .local)
        MockURLProtocol.register(tag) { request in
            #expect(request.url!.path.contains("/api/v1/memories/search"))
            let body = TestHelper.jsonData([
                "status": "success",
                "message": "ok",
                "result": [
                    "memories": [] as [Any],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        var builder = SearchMemoriesBuilder()
        builder.userId = "u1"
        builder.query = "test"
        _ = try await client.searchMemories(builder)
    }
}
