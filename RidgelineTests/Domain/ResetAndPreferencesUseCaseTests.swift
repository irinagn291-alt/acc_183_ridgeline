import XCTest
@testable import Ridgeline

final class ResetAndPreferencesUseCaseTests: XCTestCase {
    func test_givenData_whenResetting_thenStoresAreEmptyAndOnboardingResets() async throws {
        // Given
        let routes = InMemoryTrailRouteRepository()
        let ascents = InMemoryAscentLogRepository()
        let gear = InMemoryGearNoteRepository()
        let onboarding = InMemoryOnboardingStore()
        onboarding.markOnboardingComplete()
        try await routes.save(RidgelineFixtures.route())
        try await ascents.save(RidgelineFixtures.ascent())
        try await gear.save(RidgelineFixtures.gear())

        // When
        try await ResetRidgelineDataUseCase(
            ascentRepository: ascents,
            routeRepository: routes,
            gearRepository: gear,
            onboardingStore: onboarding
        )()

        // Then
        let actual_1 = try await routes.count()
        XCTAssertEqual(actual_1, 0)
        let actual_2 = try await ascents.count()
        XCTAssertEqual(actual_2, 0)
        let actual_3 = try await gear.count()
        XCTAssertEqual(actual_3, 0)
        XCTAssertFalse(onboarding.hasCompletedOnboarding())
    }

    func test_givenPreferences_whenSaving_thenLoadReturnsSame() {
        // Given
        let store = InMemoryPreferencesStore()
        let prefs = Preferences(unitSystem: .imperial, parallaxEnabled: false)

        // When
        SavePreferencesUseCase(store: store)(prefs)

        // Then
        let loaded = LoadPreferencesUseCase(store: store)()
        XCTAssertEqual(loaded.unitSystem, .imperial)
        XCTAssertFalse(loaded.parallaxEnabled)
    }
}
