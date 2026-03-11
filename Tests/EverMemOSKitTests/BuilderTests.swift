import Testing
import Foundation
@testable import EverMemOSKit

@Suite("Builder Pattern", .serialized)
struct BuilderTests {
    @Test("FetchMemoriesBuilder defaults")
    func testFetchDefaults() {
        let builder = FetchMemoriesBuilder()
        let params = builder.build()
        #expect(params["page"] == "1")
        #expect(params["page_size"] == "20")
        #expect(params["memory_type"] == "episodic_memory")
        #expect(params["user_id"] == nil)
        #expect(params["group_ids"] == nil)
    }

    @Test("SearchMemoriesBuilder full params")
    func testSearchFullParams() {
        var builder = SearchMemoriesBuilder()
        builder.userId = "u1"
        builder.groupIds = ["g1", "g2"]
        builder.query = "coffee"
        builder.memoryTypes = [.episodicMemory, .eventLog]
        builder.retrieveMethod = .hybrid
        builder.topK = 10
        builder.radius = 0.7
        let params = builder.build()
        #expect(params["user_id"] == "u1")
        #expect(params["group_ids"] == "[\"g1\",\"g2\"]")
        #expect(params["query"] == "coffee")
        #expect(params["retrieve_method"] == "hybrid")
        #expect(params["top_k"] == "10")
        #expect(params["radius"] == "0.7")
        #expect(params["memory_types"] == "[\"episodic_memory\",\"event_log\"]")
    }

    @Test("FetchMemoriesBuilder with all params")
    func testFetchAllParams() {
        var builder = FetchMemoriesBuilder()
        builder.userId = "u1"
        builder.groupIds = ["g1"]
        builder.memoryType = .foresight
        builder.page = 2
        builder.pageSize = 100
        builder.startTime = "2025-01-01T00:00:00Z"
        builder.endTime = "2025-12-31T23:59:59Z"
        let params = builder.build()
        #expect(params["user_id"] == "u1")
        #expect(params["group_ids"] == "[\"g1\"]")
        #expect(params["memory_type"] == "foresight")
        #expect(params["start_time"] == "2025-01-01T00:00:00Z")
        #expect(params["page"] == "2")
        #expect(params["page_size"] == "100")
    }
}
