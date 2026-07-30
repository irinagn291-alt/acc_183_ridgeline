import Foundation

/// One logged climb: distance, gain, duration and derived pace.
public struct AscentLog: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var routeID: UUID?
    public var title: String
    public var climbedAt: Date
    public var distanceKilometers: Double
    public var elevationGainMeters: Double
    public var durationMinutes: Double
    public var notes: String

    public init(
        id: UUID = UUID(),
        routeID: UUID? = nil,
        title: String,
        climbedAt: Date = Date(),
        distanceKilometers: Double,
        elevationGainMeters: Double,
        durationMinutes: Double,
        notes: String = ""
    ) {
        self.id = id
        self.routeID = routeID
        self.title = title
        self.climbedAt = climbedAt
        self.distanceKilometers = distanceKilometers
        self.elevationGainMeters = elevationGainMeters
        self.durationMinutes = durationMinutes
        self.notes = notes
    }

    /// Average pace in minutes per kilometre. Nil when distance is zero.
    public var paceMinutesPerKilometer: Double? {
        guard distanceKilometers > 0 else { return nil }
        return durationMinutes / distanceKilometers
    }

    /// Average grade as a fraction (rise over run). Nil when distance is zero.
    public var gradeFraction: Double? {
        guard distanceKilometers > 0 else { return nil }
        return elevationGainMeters / (distanceKilometers * 1_000)
    }
}
