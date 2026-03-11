import Foundation
import os.log

/// Internal HTTP transport layer handling requests, retries, and response decoding.
actor HTTPTransport {
    private let config: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let logger: Logger

    init(config: Configuration, session: URLSession? = nil) {
        self.config = config
        self.session = session ?? URLSession(configuration: .default)
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        self.logger = Logger(subsystem: "EverMemOSKit", category: "HTTP")
    }

    // MARK: - Pattern 1: BaseAPIResponse<T>

    func requestBaseAPI<T: Decodable & Sendable>(
        method: String,
        path: String,
        query: [String: String]? = nil,
        body: (any Encodable & Sendable)? = nil
    ) async throws -> T {
        let data = try await performRequest(method: method, path: path, query: query, body: body)
        if config.logLevel.rawValue >= Configuration.LogLevel.debug.rawValue {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            logger.debug("requestBaseAPI raw response (\(path)): \(raw.prefix(2000))")
        }
        let response = try decoder.decode(BaseAPIResponse<T>.self, from: data)
        if config.logLevel.rawValue >= Configuration.LogLevel.info.rawValue {
            logger.info("requestBaseAPI (\(path)) status=\(response.status) message=\(response.message) hasResult=\(response.result != nil)")
        }
        // Fail only on explicit error status; HTTP 200 + non-error status (e.g. "queued") = success
        let status = response.status.lowercased()
        if status == "error" || status == "fail" || status == "failed" {
            throw EverMemOSError.apiError(statusCode: 0, message: "[\(response.status)] \(response.message)")
        }
        if let result = response.result {
            return result
        }
        // result is nil (e.g. async queued) — decode default T from empty JSON
        return try decoder.decode(T.self, from: Data("{}".utf8))
    }

    // MARK: - Pattern 2: SuccessResponse<T>

    func requestSuccess<T: Decodable & Sendable>(
        method: String,
        path: String,
        query: [String: String]? = nil,
        body: (any Encodable & Sendable)? = nil
    ) async throws -> SuccessResponse<T> {
        let data = try await performRequest(method: method, path: path, query: query, body: body)
        return try decoder.decode(SuccessResponse<T>.self, from: data)
    }

    // MARK: - Pattern 3: Bare object

    func requestBare<T: Decodable & Sendable>(
        method: String,
        path: String,
        query: [String: String]? = nil,
        body: (any Encodable & Sendable)? = nil
    ) async throws -> T {
        let data = try await performRequest(method: method, path: path, query: query, body: body)
        return try decoder.decode(T.self, from: data)
    }

    // MARK: - Core Request

    private func performRequest(
        method: String,
        path: String,
        query: [String: String]?,
        body: (any Encodable & Sendable)?
    ) async throws -> Data {
        var lastError: Error?
        for attempt in 0...config.maxRetries {
            do {
                let request = try await buildRequest(
                    method: method, path: path, query: query, body: body
                )
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw EverMemOSError.networkError("Invalid response")
                }
                guard (200...299).contains(http.statusCode) else {
                    let msg = String(data: data, encoding: .utf8) ?? ""
                    let error = EverMemOSError.apiError(
                        statusCode: http.statusCode, message: msg
                    )
                    if isRetryable(statusCode: http.statusCode), attempt < config.maxRetries {
                        lastError = error
                        try await Task.sleep(
                            nanoseconds: UInt64(config.retryDelay * 1_000_000_000)
                        )
                        continue
                    }
                    throw error
                }
                return data
            } catch let error as EverMemOSError {
                throw error
            } catch {
                if attempt < config.maxRetries {
                    lastError = error
                    try await Task.sleep(
                        nanoseconds: UInt64(config.retryDelay * 1_000_000_000)
                    )
                    continue
                }
                throw error
            }
        }
        throw lastError ?? EverMemOSError.networkError("Max retries exceeded")
    }

    // MARK: - Build Request

    private func buildRequest(
        method: String,
        path: String,
        query: [String: String]?,
        body: (any Encodable & Sendable)?
    ) async throws -> URLRequest {
        var components = URLComponents(
            url: config.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!
        if let query, !query.isEmpty {
            components.queryItems = query.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.timeoutInterval = config.timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in config.additionalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        await config.auth.applyAuth(to: &request)
        return request
    }

    private func isRetryable(statusCode: Int) -> Bool {
        statusCode == 429 || (500...599).contains(statusCode)
    }
}

// MARK: - Error

public enum EverMemOSError: LocalizedError, Sendable {
    case networkError(String)
    case apiError(statusCode: Int, message: String)
    case invalidParameter(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "Network error: \(msg)"
        case .apiError(let code, let msg): return "API error (\(code)): \(msg)"
        case .invalidParameter(let msg): return "Invalid parameter: \(msg)"
        }
    }
}

// MARK: - Type-erased Encodable wrapper

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        self._encode = { encoder in try value.encode(to: encoder) }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
