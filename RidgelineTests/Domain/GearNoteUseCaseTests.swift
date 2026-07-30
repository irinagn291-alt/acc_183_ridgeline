import XCTest
@testable import Ridgeline

final class GearNoteUseCaseTests: XCTestCase {
    private var repository: InMemoryGearNoteRepository!

    override func setUp() {
        super.setUp()
        repository = InMemoryGearNoteRepository()
    }

    func test_givenValidTitle_whenCreatingNote_thenItIsSaved() async throws {
        // Given
        let create = CreateGearNoteUseCase(repository: repository)

        // When
        let note = try await create(title: "Poles", detail: "Carbon")

        // Then
        let all = try await LoadGearNotesUseCase(repository: repository)()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(note.title, "Poles")
    }

    func test_givenBlankTitle_whenCreatingNote_thenItThrows() async {
        // Given
        let create = CreateGearNoteUseCase(repository: repository)

        // When / Then
        do {
            _ = try await create(title: "  ")
            XCTFail("Expected blank name")
        } catch let error as RidgelineError {
            XCTAssertEqual(error, .blankName)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_givenNote_whenUpdating_thenDetailChanges() async throws {
        // Given
        var note = try await CreateGearNoteUseCase(repository: repository)(title: "Shell")
        note.detail = "Hard shell"

        // When
        _ = try await UpdateGearNoteUseCase(repository: repository)(note)

        // Then
        let loaded = try await repository.fetch(id: note.id)
        XCTAssertEqual(loaded?.detail, "Hard shell")
    }

    func test_givenNote_whenDeleting_thenItIsGone() async throws {
        // Given
        let note = try await CreateGearNoteUseCase(repository: repository)(title: "Gone")

        // When
        try await DeleteGearNoteUseCase(repository: repository)(id: note.id)

        // Then
        let actual_1 = try await repository.count()
        XCTAssertEqual(actual_1, 0)
    }

    func test_givenAscentID_whenFetchingForAscent_thenOnlyMatchingReturn() async throws {
        // Given
        let ascentID = UUID()
        _ = try await CreateGearNoteUseCase(repository: repository)(
            title: "Mine", ascentID: ascentID
        )
        _ = try await CreateGearNoteUseCase(repository: repository)(
            title: "Other", ascentID: UUID()
        )

        // When
        let notes = try await LoadGearNotesForAscentUseCase(repository: repository)(ascentID: ascentID)

        // Then
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.title, "Mine")
    }
}
