import XCTest
@testable import Ridgeline

final class AscentLogUseCaseTests: XCTestCase {
    private var repository: InMemoryAscentLogRepository!

    override func setUp() {
        super.setUp()
        repository = InMemoryAscentLogRepository()
    }

    func test_givenValidInput_whenCreatingAscent_thenPaceIsDerived() async throws {
        // Given
        let create = CreateAscentUseCase(repository: repository)

        // When
        let ascent = try await create(
            title: "Summit",
            distanceKilometers: 10,
            elevationGainMeters: 500,
            durationMinutes: 200
        )

        // Then
        XCTAssertEqual(ascent.paceMinutesPerKilometer, 20)
        let actual_1 = try await repository.count()
        XCTAssertEqual(actual_1, 1)
    }

    func test_givenBlankTitle_whenCreatingAscent_thenItThrows() async {
        // Given
        let create = CreateAscentUseCase(repository: repository)

        // When / Then
        do {
            _ = try await create(
                title: " ",
                distanceKilometers: 1,
                elevationGainMeters: 1,
                durationMinutes: 1
            )
            XCTFail("Expected blank name")
        } catch let error as RidgelineError {
            XCTAssertEqual(error, .blankName)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_givenZeroDistance_whenCreatingAscent_thenItThrows() async {
        // Given
        let create = CreateAscentUseCase(repository: repository)

        // When / Then
        do {
            _ = try await create(
                title: "Bad",
                distanceKilometers: 0,
                elevationGainMeters: 100,
                durationMinutes: 60
            )
            XCTFail("Expected invalid measurement")
        } catch let error as RidgelineError {
            XCTAssertEqual(error, .invalidMeasurement)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_givenAscent_whenUpdating_thenChangesPersist() async throws {
        // Given
        var ascent = try await CreateAscentUseCase(repository: repository)(
            title: "Old",
            distanceKilometers: 5,
            elevationGainMeters: 200,
            durationMinutes: 100
        )
        ascent.title = "Updated"

        // When
        _ = try await UpdateAscentUseCase(repository: repository)(ascent)

        // Then
        let loaded = try await LoadAscentUseCase(repository: repository)(id: ascent.id)
        XCTAssertEqual(loaded.title, "Updated")
    }

    func test_givenAscent_whenDeleting_thenJournalIsEmpty() async throws {
        // Given
        let ascent = try await CreateAscentUseCase(repository: repository)(
            title: "Temp",
            distanceKilometers: 5,
            elevationGainMeters: 200,
            durationMinutes: 100
        )

        // When
        try await DeleteAscentUseCase(repository: repository)(id: ascent.id)

        // Then
        let empty = try await JournalIsEmptyUseCase(repository: repository)()
        XCTAssertTrue(empty)
    }

    func test_givenMissingAscent_whenLoading_thenItThrows() async {
        // Given
        let id = UUID()

        // When / Then
        do {
            _ = try await LoadAscentUseCase(repository: repository)(id: id)
            XCTFail("Expected not found")
        } catch let error as RidgelineError {
            XCTAssertEqual(error, .ascentNotFound(id))
        } catch {
            XCTFail("Unexpected error")
        }
    }
}
