import XCTest
@testable import Ridgeline

@MainActor
final class OnboardingAscentViewModelTests: XCTestCase {
    func test_givenValidClimb_whenDrawingTheRidge_thenAscentIsSaved() async throws {
        // Given — same path as tapping "Draw the ridge" during onboarding.
        let store = try RidgelineDataStore(location: .inMemory, name: "OnboardingCrash")
        let routes = CoreDataTrailRouteRepository(store: store)
        let ascents = CoreDataAscentLogRepository(store: store)
        let onboarding = UserDefaultsOnboardingStore(
            defaults: UserDefaults(suiteName: "com.ridgeline.ascent.tests.onboarding") ?? .standard
        )
        onboarding.resetOnboarding()

        let viewModel = OnboardingAscentViewModel(
            createAscent: CreateAscentUseCase(repository: ascents),
            createRoute: CreateTrailRouteUseCase(repository: routes),
            onboardingStore: onboarding
        )
        viewModel.title = "Copper Ridge"
        viewModel.distanceText = "10"
        viewModel.gainText = "650"
        viewModel.durationText = "240"

        // When
        let ok = await viewModel.continueFromEntry()

        // Then
        XCTAssertTrue(ok)
        XCTAssertEqual(viewModel.step, 1)
        XCTAssertEqual(viewModel.savedAscent?.title, "Copper Ridge")
        let ascentCount = try await ascents.count()
        let routeCount = try await routes.count()
        XCTAssertEqual(ascentCount, 1)
        XCTAssertEqual(routeCount, 1)
    }
}
