import Foundation

// MARK: - POST /api/v1/global-user-profile/custom

public struct CustomProfileData: Encodable, Sendable {
    public let initialProfile: [String]

    public init(initialProfile: [String]) {
        self.initialProfile = initialProfile
    }

    enum CodingKeys: String, CodingKey {
        case initialProfile = "initial_profile"
    }
}

public struct UpsertCustomProfileRequest: Encodable, Sendable {
    public let userId: String
    public let customProfileData: CustomProfileData

    public init(userId: String, customProfileData: CustomProfileData) {
        self.userId = userId
        self.customProfileData = customProfileData
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case customProfileData = "custom_profile_data"
    }
}
