import Foundation

/// UserDefaults-backed preferences.
public final class UserDefaultsPreferencesStore: PreferencesStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let unitKey = "com.ridgeline.ascent.unitSystem"
    private let parallaxKey = "com.ridgeline.ascent.parallaxEnabled"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> Preferences {
        let unitRaw = defaults.string(forKey: unitKey) ?? RidgeUnitSystem.metric.rawValue
        let unit = RidgeUnitSystem(rawValue: unitRaw) ?? .metric
        let parallax = defaults.object(forKey: parallaxKey) as? Bool ?? true
        return Preferences(unitSystem: unit, parallaxEnabled: parallax)
    }

    public func save(_ preferences: Preferences) {
        defaults.set(preferences.unitSystem.rawValue, forKey: unitKey)
        defaults.set(preferences.parallaxEnabled, forKey: parallaxKey)
    }
}
