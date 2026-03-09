import Foundation
@testable import EverMemOSKit

enum TestHelper {
    static func makeClient(tag: String) -> (EverMemOSClient, URLSession) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let clientConfig = Configuration(
            baseURL: URL(string: "https://\(tag).test.example.com")!,
            auth: BearerTokenAuth(token: "test-token"),
            maxRetries: 0,
            logLevel: .none
        )
        let client = EverMemOSClient(config: clientConfig, session: session)
        return (client, session)
    }

    static func jsonData(_ dict: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: dict)
    }

    static func okResponse(url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    static func errorResponse(url: URL, code: Int = 400) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
