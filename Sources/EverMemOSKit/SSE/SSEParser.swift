import Foundation

/// Parser for Server-Sent Events (SSE) text/event-stream lines.
public enum SSEParser {
    /// Parse a single "data: {...}" line into a ChatSSEData.
    public static func parse(line: String) -> ChatSSEData? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("data: ") else { return nil }
        let jsonString = String(trimmed.dropFirst(6))
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ChatSSEData.self, from: data)
    }
}
