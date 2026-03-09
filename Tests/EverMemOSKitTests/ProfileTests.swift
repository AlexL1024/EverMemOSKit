import Testing
import Foundation
@testable import EverMemOSKit

@Suite("POST /api/v1/global-user-profile/custom")
struct ProfileTests {
    @Test("Upsert profile success")
    func testUpsertSuccess() async throws {
        let tag = "profile-upsert-success"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            #expect(request.httpMethod == "POST")
            let body = TestHelper.jsonData([
                "success": true,
                "data": ["initial_profile": ["Engineer"]],
                "message": "ok",
            ] as [String: Any])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = UpsertCustomProfileRequest(
            userId: "u1",
            customProfileData: CustomProfileData(initialProfile: ["Engineer"])
        )
        let result = try await client.upsertCustomProfile(req)
        #expect(result.success == true)
    }

    @Test("Upsert profile failure")
    func testUpsertFailure() async throws {
        let tag = "profile-upsert-failure"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            (TestHelper.errorResponse(url: request.url!), Data())
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = UpsertCustomProfileRequest(
            userId: "u1",
            customProfileData: CustomProfileData(initialProfile: [])
        )
        await #expect(throws: EverMemOSError.self) {
            try await client.upsertCustomProfile(req)
        }
    }

    @Test("Upsert profile decode compat")
    func testUpsertDecodeCompat() async throws {
        let tag = "profile-upsert-decode"
        let (client, _) = TestHelper.makeClient(tag: tag)
        MockURLProtocol.register(tag) { request in
            let body = TestHelper.jsonData([
                "success": true,
            ] as [String: Any])
            return (TestHelper.okResponse(url: request.url!), body)
        }
        defer { MockURLProtocol.unregister(tag) }
        let req = UpsertCustomProfileRequest(
            userId: "u1",
            customProfileData: CustomProfileData(initialProfile: ["x"])
        )
        let result = try await client.upsertCustomProfile(req)
        #expect(result.success == true)
        #expect(result.data == nil)
    }
}
