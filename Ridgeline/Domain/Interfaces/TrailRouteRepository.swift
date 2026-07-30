import Foundation

/// Persistence for named trails.
public protocol TrailRouteRepository: Sendable {
    func fetchAll() async throws -> [TrailRoute]
    func fetch(id: UUID) async throws -> TrailRoute?
    func save(_ route: TrailRoute) async throws
    func delete(id: UUID) async throws
    func count() async throws -> Int
}
