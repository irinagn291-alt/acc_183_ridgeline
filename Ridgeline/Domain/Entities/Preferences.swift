import Foundation

/// Display units for distance and elevation.
public enum RidgeUnitSystem: String, Codable, Sendable, CaseIterable, Hashable {
    case metric
    case imperial

    public var label: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }
}

/// User preferences for the journal.
public struct Preferences: Hashable, Sendable {
    public var unitSystem: RidgeUnitSystem
    public var parallaxEnabled: Bool

    public init(unitSystem: RidgeUnitSystem = .metric, parallaxEnabled: Bool = true) {
        self.unitSystem = unitSystem
        self.parallaxEnabled = parallaxEnabled
    }

    public static let `default` = Preferences()
}
