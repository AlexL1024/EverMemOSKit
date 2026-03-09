import Testing
import Foundation
@testable import EverMemOSKit

@Suite("HMAC Auth", .serialized)
struct HMACAuthTests {
    @Test("Signature format validation")
    func testSignatureFormat() async throws {
        let auth = HMACAuth(secretKey: "test-secret")
        var request = URLRequest(url: URL(string: "https://example.com/api/v1/memories")!)
        request.httpMethod = "POST"
        await auth.applyAuth(to: &request)

        let timestamp = request.value(forHTTPHeaderField: "X-Timestamp")
        let nonce = request.value(forHTTPHeaderField: "X-Nonce")
        let signature = request.value(forHTTPHeaderField: "X-Signature")

        #expect(timestamp != nil)
        #expect(nonce != nil)
        #expect(signature != nil)
        #expect(signature!.count == 64) // SHA256 hex = 64 chars
    }

    @Test("Deterministic signature")
    func testDeterministicSignature() async throws {
        let auth = HMACAuth(secretKey: "abc-12345")
        let sig = auth.hmacSHA256(key: "abc-12345", data: "POST|/api/v1/memories|1234567890|nonce123")
        #expect(sig.count == 64)
        // Same input → same output
        let sig2 = auth.hmacSHA256(key: "abc-12345", data: "POST|/api/v1/memories|1234567890|nonce123")
        #expect(sig == sig2)
    }

    @Test("Empty key still produces signature")
    func testEmptyKey() async throws {
        let auth = HMACAuth(secretKey: "")
        let sig = auth.hmacSHA256(key: "", data: "GET|/health|0|x")
        #expect(sig.count == 64)
    }
}
