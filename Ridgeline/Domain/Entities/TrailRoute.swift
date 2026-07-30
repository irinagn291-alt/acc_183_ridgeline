import Foundation

/// A named trail used when logging ascents.
public struct TrailRoute: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var distanceKilometers: Double
    public var elevationGainMeters: Double
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        distanceKilometers: Double = 0,
        elevationGainMeters: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.distanceKilometers = distanceKilometers
        self.elevationGainMeters = elevationGainMeters
        self.createdAt = createdAt
    }
}
