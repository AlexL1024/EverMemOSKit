import Foundation

/// Configuration for EverMemOSClient.
public struct Configuration: Sendable {
    public let baseURL: URL
    public let auth: AuthProvider
    public let apiVersion: String
    public let timeoutInterval: TimeInterval
    public let maxRetries: Int
    public let retryDelay: TimeInterval
    public let logLevel: LogLevel

    public enum LogLevel: Int, Sendable {
        case none = 0, error, info, debug
    }

    public init(
        baseURL: URL,
        auth: AuthProvider,
        apiVersion: String = "v0",
        timeoutInterval: TimeInterval = 30,
        maxRetries: Int = 3,
        retryDelay: TimeInterval = 1.0,
        logLevel: LogLevel = .error
    ) {
        self.baseURL = baseURL
        self.auth = auth
        self.apiVersion = apiVersion
        self.timeoutInterval = timeoutInterval
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
        self.logLevel = logLevel
    }
}
