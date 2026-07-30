import XCTest
@testable import Ridgeline

@MainActor
final class AscentEditorViewModelTests: XCTestCase {
    func test_givenValidFields_whenSavingNewAscent_thenItSucceeds() async throws {
        // Given
        let ascents = InMemoryAscentLogRepository()
        let routes = InMemoryTrailRouteRepository()
        let gear = InMemoryGearNoteRepository()
        let viewModel = AscentEditorViewModel(
            ascentID: nil,
            loadAscent: LoadAscentUseCase(repository: ascents),
            createAscent: CreateAscentUseCase(repository: ascents),
            updateAscent: UpdateAscentUseCase(repository: ascents),
            createGearNote: CreateGearNoteUseCase(repository: gear),
            loadRoutes: LoadTrailRoutesUseCase(repository: routes)
        )
        viewModel.title = "Test Peak"
        viewModel.distanceText = "8"
        viewModel.gainText = "400"
        viewModel.durationText = "160"
        viewModel.gearTitle = "Poles"

        // When
        let ok = await viewModel.save()

        // Then
        XCTAssertTrue(ok)
        let actual_1 = try await ascents.count()
        XCTAssertEqual(actual_1, 1)
        let actual_2 = try await gear.count()
        XCTAssertEqual(actual_2, 1)
    }

    func test_givenInvalidDistance_whenSaving_thenItFails() async {
        // Given
        let ascents = InMemoryAscentLogRepository()
        let routes = InMemoryTrailRouteRepository()
        let gear = InMemoryGearNoteRepository()
        let viewModel = AscentEditorViewModel(
            ascentID: nil,
            loadAscent: LoadAscentUseCase(repository: ascents),
            createAscent: CreateAscentUseCase(repository: ascents),
            updateAscent: UpdateAscentUseCase(repository: ascents),
            createGearNote: CreateGearNoteUseCase(repository: gear),
            loadRoutes: LoadTrailRoutesUseCase(repository: routes)
        )
        viewModel.title = "Bad"
        viewModel.distanceText = "abc"
        viewModel.gainText = "100"
        viewModel.durationText = "60"

        // When
        let ok = await viewModel.save()

        // Then
        XCTAssertFalse(ok)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
