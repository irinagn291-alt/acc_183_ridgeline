import Foundation
import Observation

@Observable
@MainActor
public final class ProfileDashboardViewModel {
    public private(set) var ascents: [AscentLog] = []
    public private(set) var totals: RidgeTotals = RidgeTotals(
        totalGainMeters: 0,
        totalDistanceKilometers: 0,
        ascentCount: 0
    )
    public private(set) var profileSamples: [ElevationSample] = []
    public private(set) var preferences: Preferences = .default
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let loadAscents: LoadAscentsUseCase
    private let computeTotals: ComputeTotalGainUseCase
    private let buildProfile: BuildElevationProfileUseCase
    private let loadPreferences: LoadPreferencesUseCase

    public init(
        loadAscents: LoadAscentsUseCase,
        computeTotals: ComputeTotalGainUseCase,
        buildProfile: BuildElevationProfileUseCase,
        loadPreferences: LoadPreferencesUseCase
    ) {
        self.loadAscents = loadAscents
        self.computeTotals = computeTotals
        self.buildProfile = buildProfile
        self.loadPreferences = loadPreferences
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            ascents = try await loadAscents()
            totals = try await computeTotals()
            profileSamples = try await buildProfile()
            preferences = loadPreferences()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
