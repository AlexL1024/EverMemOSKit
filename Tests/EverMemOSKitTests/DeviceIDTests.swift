import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Device ID Support")
struct DeviceIDTests {
    @Test("DeviceIDHelper augments user_id")
    func testAugmentUserId() {
        let result = DeviceIDHelper.augment(userId: "patient", with: "abc123")
        #expect(result == "patient_abc123")
    }

    @Test("DeviceIDHelper augments group_id")
    func testAugmentGroupId() {
        let result = DeviceIDHelper.augment(groupId: "memo_group", with: "abc123")
        #expect(result == "memo_group_abc123")
    }

    @Test("DeviceIDHelper returns original when deviceId is nil")
    func testAugmentWithNilDeviceId() {
        let userId = DeviceIDHelper.augment(userId: "patient", with: nil)
        let groupId = DeviceIDHelper.augment(groupId: "memo_group", with: nil)
        #expect(userId == "patient")
        #expect(groupId == "memo_group")
    }

    @Test("Memorize request with deviceId augments sender and groupId")
    func testMemorizeWithDeviceId() async throws {
        let tag = "memorize-deviceid"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let clientConfig = Configuration(
            baseURL: URL(string: "https://\(tag).test.example.com")!,
            auth: NoAuth(),
            maxRetries: 0,
            logLevel: .none,
            deviceId: "test123"
        )
        let client = EverMemOSClient(config: clientConfig, session: session)

        var capturedBody: [String: Any]?
        MockURLProtocol.register(tag) { request in
            if let stream = request.httpBodyStream {
                stream.open()
                var data = Data()
                let bufferSize = 4096
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { buffer.deallocate() }
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: bufferSize)
                    if read > 0 {
                        data.append(buffer, count: read)
                    }
                }
                stream.close()
                capturedBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            } else if let data = request.httpBody {
                capturedBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            }
            let body = TestHelper.jsonData(["status": "ok"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        let req = MemorizeRequest(
            messageId: "msg_001",
            createTime: "2025-01-15T10:00:00+00:00",
            sender: "patient",
            content: "Test message",
            groupId: "memo_group"
        )
        _ = try await client.memorize(req)

        #expect(capturedBody?["sender"] as? String == "patient_test123")
        #expect(capturedBody?["group_id"] as? String == "memo_group_test123")
    }

    @Test("Memorize request without deviceId keeps original IDs")
    func testMemorizeWithoutDeviceId() async throws {
        let tag = "memorize-no-deviceid"
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let clientConfig = Configuration(
            baseURL: URL(string: "https://\(tag).test.example.com")!,
            auth: NoAuth(),
            maxRetries: 0,
            logLevel: .none
        )
        let client = EverMemOSClient(config: clientConfig, session: session)

        var capturedBody: [String: Any]?
        MockURLProtocol.register(tag) { request in
            if let stream = request.httpBodyStream {
                stream.open()
                var data = Data()
                let bufferSize = 4096
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer { buffer.deallocate() }
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: bufferSize)
                    if read > 0 {
                        data.append(buffer, count: read)
                    }
                }
                stream.close()
                capturedBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            } else if let data = request.httpBody {
                capturedBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            }
            let body = TestHelper.jsonData(["status": "ok"])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        let req = MemorizeRequest(
            messageId: "msg_001",
            createTime: "2025-01-15T10:00:00+00:00",
            sender: "patient",
            content: "Test message",
            groupId: "memo_group"
        )
        _ = try await client.memorize(req)

        #expect(capturedBody?["sender"] as? String == "patient")
        #expect(capturedBody?["group_id"] as? String == "memo_group")
    }
}
