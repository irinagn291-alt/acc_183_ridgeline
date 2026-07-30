import Foundation

/// Persistence for gear notes.
public protocol GearNoteRepository: Sendable {
    func fetchAll() async throws -> [GearNote]
    func fetch(id: UUID) async throws -> GearNote?
    func fetch(for ascentID: UUID) async throws -> [GearNote]
    func save(_ note: GearNote) async throws
    func delete(id: UUID) async throws
    func count() async throws -> Int
}
