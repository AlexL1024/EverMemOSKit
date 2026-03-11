import Testing
import Foundation
@testable import EverMemOSKit

@Suite("DeploymentProfile")
struct DeploymentProfileTests {

    // MARK: - Profile Properties

    @Test("Cloud profile defaults")
    func testCloudDefaults() {
        let profile = DeploymentProfile.cloud
        #expect(profile.defaultBaseURL.absoluteString == "https://api.evermind.ai")
        #expect(profile.apiVersion == "v0")
        #expect(profile.statusPathSegment == "status")
        #expect(profile.requiresAuth)
    }

    @Test("Local profile defaults")
    func testLocalDefaults() {
        let profile = DeploymentProfile.local
        #expect(profile.defaultBaseURL.absoluteString == "http://localhost:1995")
        #expect(profile.apiVersion == "v1")
        #expect(profile.statusPathSegment == "stats")
        #expect(!profile.requiresAuth)
    }

    @Test("CaseIterable includes both profiles")
    func testCaseIterable() {
        #expect(DeploymentProfile.allCases.count == 2)
        #expect(DeploymentProfile.allCases.contains(.cloud))
        #expect(DeploymentProfile.allCases.contains(.local))
    }

    @Test("RawValue round-trip")
    func testRawValue() {
        #expect(DeploymentProfile(rawValue: "cloud") == .cloud)
        #expect(DeploymentProfile(rawValue: "local") == .local)
        #expect(DeploymentProfile(rawValue: "unknown") == nil)
    }

    // MARK: - Configuration from Profile

    @Test("Configuration from cloud profile uses v0 and status")
    func testConfigFromCloud() {
        let config = Configuration(profile: .cloud)
        #expect(config.apiVersion == "v0")
        #expect(config.statusPathSegment == "status")
        #expect(config.baseURL.absoluteString == "https://api.evermind.ai")
    }

    @Test("Configuration from local profile uses v1 and stats")
    func testConfigFromLocal() {
        let config = Configuration(profile: .local)
        #expect(config.apiVersion == "v1")
        #expect(config.statusPathSegment == "stats")
        #expect(config.baseURL.absoluteString == "http://localhost:1995")
    }

    @Test("Configuration from profile allows baseURL override")
    func testConfigBaseURLOverride() {
        let custom = URL(string: "http://192.168.1.100:1995")!
        let config = Configuration(profile: .local, baseURL: custom)
        #expect(config.baseURL == custom)
        #expect(config.apiVersion == "v1")
    }

    @Test("Configuration from profile allows auth override")
    func testConfigAuthOverride() async {
        let token = BearerTokenAuth(token: "my-token")
        let config = Configuration(profile: .local, auth: token)
        // Verify the auth is applied
        var request = URLRequest(url: URL(string: "https://example.com")!)
        await config.auth.applyAuth(to: &request)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer my-token")
    }

    @Test("Default Configuration (no profile) uses v0 and status")
    func testDefaultConfig() {
        let config = Configuration(
            baseURL: URL(string: "https://example.com")!,
            auth: NoAuth()
        )
        #expect(config.apiVersion == "v0")
        #expect(config.statusPathSegment == "status")
    }

    @Test("Configuration with v1 auto-derives stats")
    func testV1AutoDerivesStats() {
        let config = Configuration(
            baseURL: URL(string: "https://example.com")!,
            auth: NoAuth(),
            apiVersion: "v1"
        )
        #expect(config.statusPathSegment == "stats")
    }

    @Test("Configuration with explicit statusPathSegment overrides auto-derive")
    func testExplicitStatusPath() {
        let config = Configuration(
            baseURL: URL(string: "https://example.com")!,
            auth: NoAuth(),
            apiVersion: "v1",
            statusPathSegment: "custom-status"
        )
        #expect(config.statusPathSegment == "custom-status")
    }
}
