import Foundation

enum QueryEncoding {
    static func jsonArrayString(_ values: [String]) -> String {
        // The Evermind API docs specify "array format" for `group_ids` and `memory_types`.
        // Query parameters don't have a native array type, so encode as a JSON array string.
        let data = try! JSONEncoder().encode(values)
        return String(decoding: data, as: UTF8.self)
    }
}

