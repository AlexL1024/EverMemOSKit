import Foundation
#if canImport(CommonCrypto)
import CommonCrypto
#endif

/// HMAC-SHA256 authentication.
/// Signature format: {METHOD}|{URL_PATH}|{TIMESTAMP}|{NONCE}
public struct HMACAuth: AuthProvider {
    private let secretKey: String

    public init(secretKey: String) {
        self.secretKey = secretKey
    }

    public func applyAuth(to request: inout URLRequest) async {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? "/"
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let nonce = UUID().uuidString

        let signatureData = "\(method)|\(path)|\(timestamp)|\(nonce)"
        let signature = hmacSHA256(key: secretKey, data: signatureData)

        request.setValue(timestamp, forHTTPHeaderField: "X-Timestamp")
        request.setValue(nonce, forHTTPHeaderField: "X-Nonce")
        request.setValue(signature, forHTTPHeaderField: "X-Signature")
    }

    func hmacSHA256(key: String, data: String) -> String {
        let keyData = Array(key.utf8)
        let dataBytes = Array(data.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyData, keyData.count, dataBytes, dataBytes.count, &digest)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
