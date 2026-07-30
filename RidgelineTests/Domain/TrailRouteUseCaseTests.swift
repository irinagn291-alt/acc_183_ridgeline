import XCTest
@testable import Ridgeline

final class TrailRouteUseCaseTests: XCTestCase {
    private var repository: InMemoryTrailRouteRepository!

    override func setUp() {
        super.setUp()
        repository = InMemoryTrailRouteRepository()
    }

    func test_givenEmptyStore_whenCreatingRoute_thenItIsSaved() async throws {
        // Given
        let create = CreateTrailRouteUseCase(repository: repository)

        // When
        let route = try await create(name: "Copper Ridge", distanceKilometers: 12, elevationGainMeters: 800)

        // Then
        let loaded = try await LoadTrailRouteUseCase(repository: repository)(id: route.id)
        XCTAssertEqual(loaded.name, "Copper Ridge")
        XCTAssertEqual(loaded.distanceKilometers, 12)
    }

    func test_givenBlankName_whenCreatingRoute_thenItThrows() async {
        // Given
        let create = CreateTrailRouteUseCase(repository: repository)

        // When / Then
        do {
            _ = try await create(name: "   ", distanceKilometers: 1, elevationGainMeters: 1)
            XCTFail("Expected blank name")
        } catch let error as RidgelineError {
            XCTAssertEqual(error, .blankName)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_givenRoute_whenUpdating_thenFieldsChange() async throws {
        // Given
        var route = try await CreateTrailRouteUseCase(repository: repository)(
            name: "Old", distanceKilometers: 5, elevationGainMeters: 200
        )
        route.name = "New"

        // When
        _ = try await UpdateTrailRouteUseCase(repository: repository)(route)

        // Then
        let loaded = try await LoadTrailRouteUseCase(repository: repository)(id: route.id)
        XCTAssertEqual(loaded.name, "New")
    }

    func test_givenRoute_whenDeleting_thenItIsGone() async throws {
        // Given
        let route = try await CreateTrailRouteUseCase(repository: repository)(
            name: "Gone", distanceKilometers: 1, elevationGainMeters: 1
        )

        // When
        try await DeleteTrailRouteUseCase(repository: repository)(id: route.id)

        // Then
        let all = try await LoadTrailRoutesUseCase(repository: repository)()
        XCTAssertTrue(all.isEmpty)
    }

    func test_givenMissingRoute_whenLoading_thenItThrows() async {
        // Given
        let id = UUID()

        // When / Then
        do {
            _ = try await LoadTrailRouteUseCase(repository: repository)(id: id)
            XCTFail("Expected not found")
        } catch let error as RidgelineError {
            XCTAssertEqual(error, .routeNotFound(id))
        } catch {
            XCTFail("Unexpected error")
        }
    }
}
