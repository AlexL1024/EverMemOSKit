import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Fetch API contract", .serialized)
struct FetchRequestTests {

    // MARK: - Query params (used at runtime — iOS rejects GET+body)

    @Test("build() produces correct query param names matching API spec")
    func testQueryParamKeys() {
        var builder = FetchMemoriesBuilder()
        builder.userId = "captain"
        builder.setGroupId("captain_about_doctor")
        builder.memoryType = .episodicMemory
        builder.page = 2
        builder.pageSize = 50
        builder.startTime = "2026-03-01T00:00:00Z"
        builder.endTime = "2026-03-07T23:59:59Z"

        let params = builder.build()
        #expect(params["user_id"] == "captain")
        #expect(params["group_ids"] == "captain_about_doctor")
        #expect(params["memory_type"] == "episodic_memory")
        #expect(params["page"] == "2")
        #expect(params["page_size"] == "50")
        #expect(params["start_time"] == "2026-03-01T00:00:00Z")
        #expect(params["end_time"] == "2026-03-07T23:59:59Z")

        // Must NOT contain old wrong field names
        #expect(params["group_id"] == nil)
        #expect(params["limit"] == nil)
        #expect(params["offset"] == nil)
    }

    @Test("build() omits group_ids when empty")
    func testEmptyGroupIdsOmitted() {
        var builder = FetchMemoriesBuilder()
        builder.userId = "captain"

        let params = builder.build()
        #expect(params["group_ids"] == nil)
        #expect(params["user_id"] == "captain")
    }

    @Test("build() joins multiple group_ids with comma")
    func testMultipleGroupIds() {
        var builder = FetchMemoriesBuilder()
        builder.userId = "captain"
        builder.groupIds = ["captain_about_doctor", "captain_about_stowaway", "captain_about_aurora"]

        let params = builder.build()
        let ids = params["group_ids"]!.split(separator: ",").map(String.init)
        #expect(ids.count == 3)
        #expect(ids.contains("captain_about_doctor"))
        #expect(ids.contains("captain_about_stowaway"))
        #expect(ids.contains("captain_about_aurora"))
    }

    // MARK: - Request body encoding (kept for schema verification)

    @Test("RequestBody encodes correct JSON key names")
    func testRequestBodyKeys() throws {
        var builder = FetchMemoriesBuilder()
        builder.userId = "captain"
        builder.setGroupId("captain_about_doctor")
        builder.memoryType = .episodicMemory
        builder.page = 2
        builder.pageSize = 50

        let body = FetchMemoriesRequestBody(from: builder)
        let data = try JSONEncoder().encode(body)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["user_id"] as? String == "captain")
        #expect(json["group_ids"] as? [String] == ["captain_about_doctor"])
        #expect(json["memory_type"] as? String == "episodic_memory")
        #expect(json["page"] as? Int == 2)
        #expect(json["page_size"] as? Int == 50)
    }

    @Test("setGroupId convenience wraps single id into array")
    func testSetGroupId() {
        var builder = FetchMemoriesBuilder()
        builder.setGroupId("captain_about_doctor")
        #expect(builder.groupIds == ["captain_about_doctor"])
    }

    @Test("Default values match API defaults")
    func testDefaults() {
        let builder = FetchMemoriesBuilder()
        #expect(builder.page == 1)
        #expect(builder.pageSize == 20)
        #expect(builder.memoryType == .episodicMemory)
        #expect(builder.groupIds.isEmpty)
        #expect(builder.userId == nil)
    }

    // MARK: - Response parsing

    @Test("Parses episodic memories with group_id, episode, summary")
    func testParseEpisodicMemories() async throws {
        let tag = "fetch-req-episodic"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "GET")
            // Verify query params are in the URL (not body)
            let urlString = request.url!.absoluteString
            #expect(urlString.contains("user_id=captain"))
            #expect(urlString.contains("memory_type=episodic_memory"))
            #expect(request.httpBody == nil)
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "memories": [
                        [
                            "memory_type": "episodic_memory",
                            "user_id": "captain",
                            "group_id": "captain_about_doctor",
                            "group_name": "船长-关于医生",
                            "episode": "船长在酒吧和医生聊了体检的事",
                            "summary": "船长与医生讨论体检",
                            "subject": "体检",
                            "keywords": ["体检", "酒吧"],
                        ] as [String: Any],
                        [
                            "memory_type": "episodic_memory",
                            "user_id": "captain",
                            "group_id": "captain_about_stowaway",
                            "episode": "船长远远看了少年一眼",
                            "summary": "船长观察少年",
                        ] as [String: Any],
                    ] as [[String: Any]],
                    "total_count": 2,
                    "count": 2,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        var builder = FetchMemoriesBuilder()
        builder.userId = "captain"
        let result = try await client.fetchMemories(builder)

        #expect(result.memories.count == 2)
        #expect(result.totalCount == 2)
        #expect(result.count == 2)

        let first = result.memories[0]
        #expect(first.groupId == "captain_about_doctor")
        #expect(first.episode == "船长在酒吧和医生聊了体检的事")
        #expect(first.summary == "船长与医生讨论体检")
        // Episodic memories don't have 'content' field
        #expect(first.content == nil)

        let second = result.memories[1]
        #expect(second.groupId == "captain_about_stowaway")
        #expect(second.episode == "船长远远看了少年一眼")
    }

    @Test("Parses event_log with atomic_fact")
    func testParseEventLog() async throws {
        let tag = "fetch-req-eventlog"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "memories": [
                        [
                            "memory_type": "event_log",
                            "user_id": "doctor",
                            "group_id": "doctor_about_stowaway",
                            "atomic_fact": "医生注意到少年回避了反应堆话题",
                        ] as [String: Any],
                    ] as [[String: Any]],
                    "total_count": 1,
                    "count": 1,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        var builder = FetchMemoriesBuilder()
        builder.userId = "doctor"
        builder.memoryType = .eventLog
        let result = try await client.fetchMemories(builder)

        #expect(result.memories.count == 1)
        #expect(result.memories[0].atomicFact == "医生注意到少年回避了反应堆话题")
        #expect(result.memories[0].groupId == "doctor_about_stowaway")
    }

    @Test("Empty result decodes gracefully")
    func testEmptyResult() async throws {
        let tag = "fetch-req-empty"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "total_count": 0,
                    "count": 0,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        var builder = FetchMemoriesBuilder()
        builder.userId = "nobody"
        let result = try await client.fetchMemories(builder)
        #expect(result.memories.isEmpty)
        #expect(result.totalCount == 0)
    }

    @Test("Memories from different groups have correct groupId")
    func testGroupIdPreserved() async throws {
        let tag = "fetch-req-groups"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "status": "ok", "message": "ok",
                "result": [
                    "memories": [
                        ["group_id": "a_about_b", "episode": "memory 1"] as [String: Any],
                        ["group_id": "a_about_c", "episode": "memory 2"] as [String: Any],
                        ["group_id": "a_about_b", "episode": "memory 3"] as [String: Any],
                    ] as [[String: Any]],
                    "total_count": 3,
                    "count": 3,
                ] as [String: Any],
            ])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }

        var builder = FetchMemoriesBuilder()
        builder.userId = "a"
        let result = try await client.fetchMemories(builder)

        #expect(result.memories.count == 3)
        #expect(result.memories[0].groupId == "a_about_b")
        #expect(result.memories[1].groupId == "a_about_c")
        #expect(result.memories[2].groupId == "a_about_b")
    }
}
