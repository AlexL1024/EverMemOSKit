# QuickStart Example

This example shows the minimal integration flow for `EverMemOSKit`.

## Flow

1. Create a `Configuration`
2. Create an `EverMemOSClient`
3. Write memory with `memorize`
4. Retrieve memory with `fetchMemories` or `searchMemories`
5. Use memory-aware responses with `chatStream`

## Minimal Example

```swift
import Foundation
import EverMemOSKit

func runExample() async throws {
    let client = EverMemOSClient(
        config: Configuration(
            baseURL: URL(string: "https://api.evermind.ai")!,
            auth: BearerTokenAuth(token: "your-token")
        )
    )

    let write = MemorizeRequest(
        messageId: UUID().uuidString,
        createTime: ISO8601DateFormatter().string(from: Date()),
        sender: "user_001",
        content: "Alice prefers oat milk.",
        groupId: "preferences",
        groupName: "User Preferences",
        senderName: "Example App",
        role: "system"
    )

    _ = try await client.memorize(write)

    var search = SearchMemoriesBuilder()
    search.userId = "user_001"
    search.query = "oat milk"
    search.topK = 3

    let results = try await client.searchMemories(search)
    print(results.memories.count)
}
```
