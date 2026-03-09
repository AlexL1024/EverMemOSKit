import Testing
import Foundation
@testable import EverMemOSKit

@Suite("SSE Parsing", .serialized)
struct ChatStreamTests {
    @Test("Parse multiple SSE events")
    func testParseMultipleEvents() {
        let lines = [
            "data: {\"type\":\"delta\",\"content\":\"Hello\"}",
            "data: {\"type\":\"evidence\",\"citations\":[]}",
            "data: {\"type\":\"done\"}",
        ]
        var events: [ChatSSEData] = []
        for line in lines {
            if let event = SSEParser.parse(line: line) {
                events.append(event)
            }
        }
        #expect(events.count == 3)
        #expect(events[0].eventType == .delta)
        #expect(events[0].content == "Hello")
        #expect(events[2].eventType == .done)
    }

    @Test("Parse error event")
    func testParseErrorEvent() {
        let line = "data: {\"type\":\"error\",\"error\":\"Something went wrong\"}"
        let event = SSEParser.parse(line: line)
        #expect(event != nil)
        #expect(event?.eventType == .error)
        #expect(event?.error == "Something went wrong")
    }

    @Test("Ignore non-data lines")
    func testIgnoreNonDataLines() {
        #expect(SSEParser.parse(line: ": comment") == nil)
        #expect(SSEParser.parse(line: "event: message") == nil)
        #expect(SSEParser.parse(line: "") == nil)
    }
}
