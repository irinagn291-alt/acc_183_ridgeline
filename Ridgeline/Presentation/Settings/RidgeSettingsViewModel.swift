import Foundation
import Observation

@Observable
@MainActor
public final class RidgeSettingsViewModel {
    public var preferences: Preferences = .default
    public var isResetting = false
    public var errorMessage: String?
    public var confirmReset = false

    private let loadPreferences: LoadPreferencesUseCase
    private let savePreferences: SavePreferencesUseCase
    private let resetData: ResetRidgelineDataUseCase

    public init(
        loadPreferences: LoadPreferencesUseCase,
        savePreferences: SavePreferencesUseCase,
        resetData: ResetRidgelineDataUseCase
    ) {
        self.loadPreferences = loadPreferences
        self.savePreferences = savePreferences
        self.resetData = resetData
    }

    public func load() {
        preferences = loadPreferences()
    }

    public func persist() {
        savePreferences(preferences)
    }

    public func resetJournal() async -> Bool {
        isResetting = true
        defer { isResetting = false }
        do {
            try await resetData()
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
