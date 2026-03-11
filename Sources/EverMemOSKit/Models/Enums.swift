import Foundation

// MARK: - Memory Types

public enum MemoryType: String, Codable, Sendable {
    case profile
    case episodicMemory = "episodic_memory"
    case foresight
    case eventLog = "event_log"
    case groupProfile = "group_profile"
}

// MARK: - Retrieve Methods

public enum RetrieveMethod: String, Codable, Sendable {
    case keyword
    case vector
    case hybrid
    case rrf
    case agentic
}

// MARK: - Scene Types

public enum SceneType: String, Codable, Sendable {
    case groupChat = "group_chat"
    case assistant
}

// MARK: - Message Sender Role

public enum MessageSenderRole: String, Codable, Sendable {
    case user
    case assistant
}
