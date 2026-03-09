import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Conversation Meta CRUD")
struct ConversationMetaTests {
    // MARK: - Create

    @Test("Create success")
    func testCreateSuccess() async throws {
        let tag = "convmeta-create-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "id": "abc123",
                    "scene": "group_chat",
                    "name": "Test Group",
                    "is_default": false,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ConversationMetaCreateRequest(
            scene: "group_chat",
            sceneDesc: ["description": .string("test")],
            name: "Test Group",
            createdAt: "2025-01-15T10:00:00+00:00"
        )
        let result = try await client.createConversationMeta(req)
        #expect(result.id == "abc123")
        #expect(result.scene == "group_chat")
    }

    @Test("Create failure — missing required fields")
    func testCreateFailure() async throws {
        let tag = "convmeta-create-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData(["detail": "Validation error"])
            return (TestHelper.errorResponse(url: request.url!, code: 422), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ConversationMetaCreateRequest(
            scene: "group_chat",
            sceneDesc: [:],
            name: "Test",
            createdAt: "2025-01-15T10:00:00+00:00"
        )
        await #expect(throws: EverMemOSError.self) {
            try await client.createConversationMeta(req)
        }
    }

    @Test("Create decode compat")
    func testCreateDecodeCompat() async throws {
        let tag = "convmeta-create-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "id": "x", "scene": "assistant", "name": "N",
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ConversationMetaCreateRequest(
            scene: "assistant", sceneDesc: [:],
            name: "N", createdAt: "2025-01-01T00:00:00Z"
        )
        let result = try await client.createConversationMeta(req)
        #expect(result.tags.isEmpty)
        #expect(result.isDefault == false)
    }

    // MARK: - Get

    @Test("Get success")
    func testGetSuccess() async throws {
        let tag = "convmeta-get-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "id": "abc", "scene": "group_chat",
                    "name": "G", "is_default": false,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.getConversationMeta(groupId: "g1")
        #expect(result.id == "abc")
    }

    @Test("Get failure")
    func testGetFailure() async throws {
        let tag = "convmeta-get-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!, code: 404), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        await #expect(throws: EverMemOSError.self) {
            try await client.getConversationMeta(groupId: "missing")
        }
    }

    @Test("Get decode compat — default fallback")
    func testGetDecodeCompat() async throws {
        let tag = "convmeta-get-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "id": "def", "scene": "assistant",
                    "name": "Default", "is_default": true,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let result = try await client.getConversationMeta()
        #expect(result.isDefault == true)
        #expect(result.userDetails.isEmpty)
    }

    // MARK: - Patch

    @Test("Patch success")
    func testPatchSuccess() async throws {
        let tag = "convmeta-patch-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "PATCH")
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "id": "abc", "updated_fields": ["name"],
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ConversationMetaPatchRequest(groupId: "g1", name: "New")
        let result = try await client.patchConversationMeta(req)
        #expect(result.updatedFields == ["name"])
    }

    @Test("Patch failure")
    func testPatchFailure() async throws {
        let tag = "convmeta-patch-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ConversationMetaPatchRequest(groupId: "g1")
        await #expect(throws: EverMemOSError.self) {
            try await client.patchConversationMeta(req)
        }
    }

    @Test("Patch decode compat")
    func testPatchDecodeCompat() async throws {
        let tag = "convmeta-patch-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": ["id": "x"] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = ConversationMetaPatchRequest(name: "N")
        let result = try await client.patchConversationMeta(req)
        #expect(result.updatedFields.isEmpty)
    }
}
