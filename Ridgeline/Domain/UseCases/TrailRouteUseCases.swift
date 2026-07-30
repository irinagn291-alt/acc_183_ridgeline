import Foundation

public struct LoadTrailRoutesUseCase: Sendable {
    private let repository: TrailRouteRepository
    public init(repository: TrailRouteRepository) { self.repository = repository }
    public func callAsFunction() async throws -> [TrailRoute] {
        try await repository.fetchAll()
    }
}

public struct LoadTrailRouteUseCase: Sendable {
    private let repository: TrailRouteRepository
    public init(repository: TrailRouteRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws -> TrailRoute {
        guard let route = try await repository.fetch(id: id) else {
            throw RidgelineError.routeNotFound(id)
        }
        return route
    }
}

public struct CreateTrailRouteUseCase: Sendable {
    private let repository: TrailRouteRepository
    public init(repository: TrailRouteRepository) { self.repository = repository }
    public func callAsFunction(
        name: String,
        distanceKilometers: Double,
        elevationGainMeters: Double,
        now: Date = Date()
    ) async throws -> TrailRoute {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RidgelineError.blankName }
        guard distanceKilometers >= 0, elevationGainMeters >= 0 else {
            throw RidgelineError.invalidMeasurement
        }
        let route = TrailRoute(
            name: trimmed,
            distanceKilometers: distanceKilometers,
            elevationGainMeters: elevationGainMeters,
            createdAt: now
        )
        try await repository.save(route)
        return route
    }
}

public struct UpdateTrailRouteUseCase: Sendable {
    private let repository: TrailRouteRepository
    public init(repository: TrailRouteRepository) { self.repository = repository }
    public func callAsFunction(_ route: TrailRoute) async throws -> TrailRoute {
        guard !route.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RidgelineError.blankName
        }
        guard route.distanceKilometers >= 0, route.elevationGainMeters >= 0 else {
            throw RidgelineError.invalidMeasurement
        }
        try await repository.save(route)
        return route
    }
}

public struct DeleteTrailRouteUseCase: Sendable {
    private let repository: TrailRouteRepository
    public init(repository: TrailRouteRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws {
        guard try await repository.fetch(id: id) != nil else {
            throw RidgelineError.routeNotFound(id)
        }
        try await repository.delete(id: id)
    }
}

public struct JournalIsEmptyUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }
    public func callAsFunction() async throws -> Bool {
        try await repository.count() == 0
    }
}
