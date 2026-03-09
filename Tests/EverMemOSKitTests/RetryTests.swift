import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Retry Logic")
struct RetryTests {
    @Test("5xx triggers retry")
    func testRetryOn5xx() async throws {
        let tag = "retry-5xx"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let clientConfig = Configuration(
            baseURL: URL(string: "https://\(tag).test.example.com")!,
            auth: BearerTokenAuth(token: "t"),
            maxRetries: 2,
            retryDelay: 0.01,
            logLevel: .none
        )
        let client = EverMemOSClient(config: clientConfig, session: session)

        var callCount = 0
        MockURLProtocol.register(tag) { request in
            callCount += 1
            if callCount < 3 {
                return (TestHelper.errorResponse(url: request.url!, code: 500), Data())
            }
            let body = TestHelper.jsonData(["status": "healthy"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.healthCheck()
        #expect(result.status == "healthy")
        #expect(callCount == 3)
    }

    @Test("4xx does not retry")
    func testNoRetryOn4xx() async throws {
        let tag = "retry-4xx"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let clientConfig = Configuration(
            baseURL: URL(string: "https://\(tag).test.example.com")!,
            auth: BearerTokenAuth(token: "t"),
            maxRetries: 2,
            retryDelay: 0.01,
            logLevel: .none
        )
        let client = EverMemOSClient(config: clientConfig, session: session)

        var callCount = 0
        MockURLProtocol.register(tag) { request in
            callCount += 1
            return (TestHelper.errorResponse(url: request.url!, code: 400), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.healthCheck()
        }
        #expect(callCount == 1)
    }

    @Test("Max retries exceeded")
    func testMaxRetriesExceeded() async throws {
        let tag = "retry-max"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let clientConfig = Configuration(
            baseURL: URL(string: "https://\(tag).test.example.com")!,
            auth: BearerTokenAuth(token: "t"),
            maxRetries: 1,
            retryDelay: 0.01,
            logLevel: .none
        )
        let client = EverMemOSClient(config: clientConfig, session: session)

        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 503), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.healthCheck()
        }
    }
}
