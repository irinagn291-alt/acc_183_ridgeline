import Foundation

/// Persistence for logged ascents.
public protocol AscentLogRepository: Sendable {
    func fetchAll() async throws -> [AscentLog]
    func fetch(id: UUID) async throws -> AscentLog?
    func save(_ ascent: AscentLog) async throws
    func delete(id: UUID) async throws
    func count() async throws -> Int
    func removeAll() async throws
}
