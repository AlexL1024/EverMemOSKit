import Testing
import Foundation
@testable import EverMemOSKit

@Suite("NoAuth")
struct NoAuthTests {
    @Test("NoAuth does not add any auth headers")
    func testNoAuthHeaders() async {
        let auth = NoAuth()
        var request = URLRequest(url: URL(string: "https://example.com")!)
        await auth.applyAuth(to: &request)
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
        #expect(request.value(forHTTPHeaderField: "X-Signature") == nil)
        #expect(request.value(forHTTPHeaderField: "X-Timestamp") == nil)
        #expect(request.value(forHTTPHeaderField: "X-Nonce") == nil)
    }

    @Test("BearerTokenAuth adds Authorization header")
    func testBearerTokenAuth() async {
        let auth = BearerTokenAuth(token: "abc123")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        await auth.applyAuth(to: &request)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer abc123")
    }
}
