import Foundation

/// Safe app-side diagnostics for patch-container resolution.
///
/// This layer does not grant privileges or bypass iOS security. It only records
/// whether the existing container-resolution path succeeded, so failures can
/// be diagnosed without changing the access mechanism.
enum PatchAccessDiagnostics {
    struct Record: Identifiable, Equatable {
        let id = UUID()
        let kind: String
        let identifier: String
        let path: String?
        let succeeded: Bool
        let date: Date
    }

    private static let lock = NSLock()
    private static var records: [Record] = []
    private static let limit = 50

    static func recordSuccess(kind: String, identifier: String, path: String) {
        append(Record(
            kind: kind,
            identifier: identifier,
            path: path,
            succeeded: true,
            date: Date()
        ))
    }

    static func recordFailure(kind: String, identifier: String) {
        append(Record(
            kind: kind,
            identifier: identifier,
            path: nil,
            succeeded: false,
            date: Date()
        ))
    }

    static var recent: [Record] {
        lock.lock()
        defer { lock.unlock() }
        return records
    }

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        records.removeAll()
    }

    static func exportText() -> String {
        let snapshot = recent
        var lines = ["Patch Access Diagnostics"]
        if snapshot.isEmpty {
            lines.append("(no container-resolution attempts recorded)")
            return lines.joined(separator: "\n")
        }

        let formatter = ISO8601DateFormatter()
        for item in snapshot {
            let result = item.succeeded ? "OK" : "FAILED"
            let path = item.path ?? "(unresolved)"
            lines.append(
                "[\(formatter.string(from: item.date))] \(result) "
                + "kind=\(item.kind) identifier=\(item.identifier) path=\(path)"
            )
        }
        return lines.joined(separator: "\n")
    }

    private static func append(_ record: Record) {
        lock.lock()
        defer { lock.unlock() }
        records.append(record)
        if records.count > limit {
            records.removeFirst(records.count - limit)
        }
    }
}
