import Foundation

public struct LoadAscentsUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }
    public func callAsFunction() async throws -> [AscentLog] {
        try await repository.fetchAll()
    }
}

public struct LoadAscentUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws -> AscentLog {
        guard let ascent = try await repository.fetch(id: id) else {
            throw RidgelineError.ascentNotFound(id)
        }
        return ascent
    }
}

public struct CreateAscentUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }
    public func callAsFunction(
        title: String,
        routeID: UUID? = nil,
        climbedAt: Date = Date(),
        distanceKilometers: Double,
        elevationGainMeters: Double,
        durationMinutes: Double,
        notes: String = ""
    ) async throws -> AscentLog {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RidgelineError.blankName }
        guard distanceKilometers > 0, elevationGainMeters >= 0, durationMinutes > 0 else {
            throw RidgelineError.invalidMeasurement
        }
        let ascent = AscentLog(
            routeID: routeID,
            title: trimmed,
            climbedAt: climbedAt,
            distanceKilometers: distanceKilometers,
            elevationGainMeters: elevationGainMeters,
            durationMinutes: durationMinutes,
            notes: notes
        )
        try await repository.save(ascent)
        return ascent
    }
}

public struct UpdateAscentUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }
    public func callAsFunction(_ ascent: AscentLog) async throws -> AscentLog {
        guard !ascent.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RidgelineError.blankName
        }
        guard ascent.distanceKilometers > 0, ascent.elevationGainMeters >= 0, ascent.durationMinutes > 0 else {
            throw RidgelineError.invalidMeasurement
        }
        try await repository.save(ascent)
        return ascent
    }
}

public struct DeleteAscentUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws {
        guard try await repository.fetch(id: id) != nil else {
            throw RidgelineError.ascentNotFound(id)
        }
        try await repository.delete(id: id)
    }
}
