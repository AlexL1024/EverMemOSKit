import Foundation
@testable import EverMemOSKit

/// Thread-safe mock URL protocol using path-based handler dispatch.
/// Each test registers a handler keyed by a unique path fragment,
/// avoiding cross-test interference during parallel execution.
final class MockURLProtocol: URLProtocol {
    private static let lock = NSLock()
    private static var _handlers: [String: (URLRequest) throws -> (HTTPURLResponse, Data)] = [:]

    /// Register a handler for requests whose path contains the given key.
    static func register(
        _ key: String,
        handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)
    ) {
        lock.lock()
        _handlers[key] = handler
        lock.unlock()
    }

    /// Remove a previously registered handler.
    static func unregister(_ key: String) {
        lock.lock()
        _handlers.removeValue(forKey: key)
        lock.unlock()
    }

    /// Remove all handlers.
    static func reset() {
        lock.lock()
        _handlers.removeAll()
        lock.unlock()
    }

    private static func findHandler(for request: URLRequest) -> ((URLRequest) throws -> (HTTPURLResponse, Data))? {
        let path = request.url?.absoluteString ?? ""
        lock.lock()
        defer { lock.unlock() }
        // Match by longest key first for specificity
        let sorted = _handlers.keys.sorted { $0.count > $1.count }
        for key in sorted {
            if path.contains(key) {
                return _handlers[key]
            }
        }
        return nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.findHandler(for: request) else {
            let error = NSError(domain: "MockURLProtocol", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "No handler for \(request.url?.absoluteString ?? "")"])
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
