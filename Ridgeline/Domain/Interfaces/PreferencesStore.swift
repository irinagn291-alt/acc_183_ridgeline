import Foundation

/// Reads and writes user preferences.
public protocol PreferencesStore: Sendable {
    func load() -> Preferences
    func save(_ preferences: Preferences)
}
