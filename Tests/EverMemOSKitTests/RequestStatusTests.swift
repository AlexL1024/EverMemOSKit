import Testing
import Foundation
@testable import EverMemOSKit

@Suite("GET /api/{v}/{statusPath}/request")
struct RequestStatusTests {
    @Test("Success — progress payload (default config → status)")
    func testRequestStatusSuccess() async throws {
        let tag = "request-status-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            #expect(request.url?.path.contains("status/request") == true)
            let body = TestHelper.jsonData([
                "success": true,
                "found": true,
                "data": [
                    "request_id": "req_test_001",
                    "status": "completed",
                    "progress": [
                        "total": 2,
                        "completed": 2,
                        "failed": 0,
                        "errors": [] as [Any],
                    ] as [String: Any],
                ] as [String: Any],
                "message": "Request found"
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        let response = try await client.getRequestStatus(requestId: "req_test_001")
        #expect(response.success == true)
        #expect(response.found == true)
        #expect(response.data?.requestId == "req_test_001")
        #expect(response.data?.progress.total == 2)
        #expect(response.data?.progress.completed == 2)
    }

    @Test("Request ID is passed as query parameter")
    func testRequestIdQueryParam() async throws {
        let tag = "request-status-query"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let query = request.url?.query ?? ""
            #expect(query.contains("request_id=my-req-123"))
            let body = TestHelper.jsonData([
                "success": true,
                "found": false,
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let response = try await client.getRequestStatus(requestId: "my-req-123")
        #expect(response.found == false)
    }
}
