import Foundation

/// Aggregate elevation and distance totals.
public struct RidgeTotals: Hashable, Sendable {
    public var totalGainMeters: Double
    public var totalDistanceKilometers: Double
    public var ascentCount: Int

    public init(totalGainMeters: Double, totalDistanceKilometers: Double, ascentCount: Int) {
        self.totalGainMeters = totalGainMeters
        self.totalDistanceKilometers = totalDistanceKilometers
        self.ascentCount = ascentCount
    }
}

/// One sample of pace against grade for charting.
public struct PaceGradePoint: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var gradePercent: Double
    public var paceMinutesPerKilometer: Double
    public var title: String

    public init(
        id: UUID = UUID(),
        gradePercent: Double,
        paceMinutesPerKilometer: Double,
        title: String
    ) {
        self.id = id
        self.gradePercent = gradePercent
        self.paceMinutesPerKilometer = paceMinutesPerKilometer
        self.title = title
    }
}

/// Distance bucket for distribution charts.
public struct DistanceBucket: Identifiable, Hashable, Sendable {
    public var id: String { label }
    public var label: String
    public var count: Int

    public init(label: String, count: Int) {
        self.label = label
        self.count = count
    }
}

/// Personal records derived from ascent history.
public struct PersonalRecords: Hashable, Sendable {
    public var highestGainMeters: Double?
    public var longestDistanceKilometers: Double?
    public var fastestPaceMinutesPerKilometer: Double?
    public var mostRecentTitle: String?

    public init(
        highestGainMeters: Double? = nil,
        longestDistanceKilometers: Double? = nil,
        fastestPaceMinutesPerKilometer: Double? = nil,
        mostRecentTitle: String? = nil
    ) {
        self.highestGainMeters = highestGainMeters
        self.longestDistanceKilometers = longestDistanceKilometers
        self.fastestPaceMinutesPerKilometer = fastestPaceMinutesPerKilometer
        self.mostRecentTitle = mostRecentTitle
    }
}

/// Kind of written insight on the Insights screen.
public enum RidgeInsightKind: String, Sendable, Hashable {
    case gain
    case pace
    case distance
    case encouragement
}

/// A short written insight about climbing habits.
public struct RidgeInsight: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var kind: RidgeInsightKind
    public var title: String
    public var detail: String

    public init(
        id: UUID = UUID(),
        kind: RidgeInsightKind,
        title: String,
        detail: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
    }
}

/// Sample points that draw a ridge cross-section profile.
public struct ElevationSample: Identifiable, Hashable, Sendable {
    public var id: Int
    public var progress: Double
    public var elevationNormalized: Double

    public init(id: Int, progress: Double, elevationNormalized: Double) {
        self.id = id
        self.progress = progress
        self.elevationNormalized = elevationNormalized
    }
}
