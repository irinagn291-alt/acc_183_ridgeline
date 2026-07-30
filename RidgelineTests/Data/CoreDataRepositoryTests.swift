import XCTest
@testable import Ridgeline

final class CoreDataTrailRouteRepositoryTests: XCTestCase {
    private var store: RidgelineDataStore!
    private var repository: CoreDataTrailRouteRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = try RidgelineDataStore(location: .inMemory, name: "RouteTest")
        repository = CoreDataTrailRouteRepository(store: store)
    }

    override func tearDown() {
        repository = nil
        store = nil
        super.tearDown()
    }

    func test_givenEmptyStore_whenFetching_thenNothingComesBack() async throws {
        // Given / When
        let routes = try await repository.fetchAll()

        // Then
        XCTAssertTrue(routes.isEmpty)
    }

    func test_givenRoute_whenSavingAndFetching_thenFieldsSurvive() async throws {
        // Given
        let route = RidgelineFixtures.route()

        // When
        try await repository.save(route)
        let loaded = try await repository.fetch(id: route.id)

        // Then
        XCTAssertEqual(loaded?.name, "Copper Ridge")
        XCTAssertEqual(loaded?.elevationGainMeters, 860)
    }

    func test_givenRoute_whenDeleting_thenItIsGone() async throws {
        // Given
        let route = RidgelineFixtures.route()
        try await repository.save(route)

        // When
        try await repository.delete(id: route.id)

        // Then
        let actual_1 = try await repository.count()
        XCTAssertEqual(actual_1, 0)
    }
}

final class CoreDataAscentLogRepositoryTests: XCTestCase {
    private var store: RidgelineDataStore!
    private var routeRepo: CoreDataTrailRouteRepository!
    private var ascentRepo: CoreDataAscentLogRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = try RidgelineDataStore(location: .inMemory, name: "AscentTest")
        routeRepo = CoreDataTrailRouteRepository(store: store)
        ascentRepo = CoreDataAscentLogRepository(store: store)
    }

    func test_givenRouteAndAscent_whenSaving_thenRelationshipSurvives() async throws {
        // Given
        let route = RidgelineFixtures.route()
        try await routeRepo.save(route)
        let ascent = RidgelineFixtures.ascent(routeID: route.id)

        // When
        try await ascentRepo.save(ascent)
        let loaded = try await ascentRepo.fetch(id: ascent.id)

        // Then
        XCTAssertEqual(loaded?.routeID, route.id)
        XCTAssertEqual(loaded?.title, "Copper Ridge summit")
    }

    func test_givenAscents_whenRemoveAll_thenCountIsZero() async throws {
        // Given
        try await ascentRepo.save(RidgelineFixtures.ascent())

        // When
        try await ascentRepo.removeAll()

        // Then
        let actual_2 = try await ascentRepo.count()
        XCTAssertEqual(actual_2, 0)
    }
}

final class CoreDataGearNoteRepositoryTests: XCTestCase {
    private var store: RidgelineDataStore!
    private var ascentRepo: CoreDataAscentLogRepository!
    private var gearRepo: CoreDataGearNoteRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        store = try RidgelineDataStore(location: .inMemory, name: "GearTest")
        ascentRepo = CoreDataAscentLogRepository(store: store)
        gearRepo = CoreDataGearNoteRepository(store: store)
    }

    func test_givenAscentAndNote_whenFetchingForAscent_thenNoteReturns() async throws {
        // Given
        let ascent = RidgelineFixtures.ascent()
        try await ascentRepo.save(ascent)
        try await gearRepo.save(RidgelineFixtures.gear(ascentID: ascent.id))

        // When
        let notes = try await gearRepo.fetch(for: ascent.id)

        // Then
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.title, "Microspikes")
    }
}

final class OnboardingStoreTests: XCTestCase {
    func test_givenFreshStore_whenChecking_thenNotComplete() {
        // Given
        let store = InMemoryOnboardingStore()

        // When / Then
        XCTAssertFalse(store.hasCompletedOnboarding())
    }

    func test_givenMarkedComplete_whenChecking_thenTrue() {
        // Given
        let store = InMemoryOnboardingStore()

        // When
        store.markOnboardingComplete()

        // Then
        XCTAssertTrue(store.hasCompletedOnboarding())
    }
}

final class SimulatorTrailSeederTests: XCTestCase {
    func test_givenEmptyStore_whenSeeding_thenAscentsAppear() async throws {
        // Given
        let store = try RidgelineDataStore(location: .inMemory, name: "SeedTest")
        let routes = CoreDataTrailRouteRepository(store: store)
        let ascents = CoreDataAscentLogRepository(store: store)
        let gear = CoreDataGearNoteRepository(store: store)

        // When
        try await SimulatorTrailSeeder(
            routeRepository: routes,
            ascentRepository: ascents,
            gearRepository: gear
        ).seedIfEmpty()

        // Then
        let actual_3 = try await ascents.count()
        XCTAssertEqual(actual_3, 3)
        let actual_4 = try await routes.count()
        XCTAssertEqual(actual_4, 2)
        let actual_5 = try await gear.count()
        XCTAssertEqual(actual_5, 1)
    }

    func test_givenExistingAscent_whenSeeding_thenNothingChanges() async throws {
        // Given
        let store = try RidgelineDataStore(location: .inMemory, name: "SeedTest2")
        let routes = CoreDataTrailRouteRepository(store: store)
        let ascents = CoreDataAscentLogRepository(store: store)
        let gear = CoreDataGearNoteRepository(store: store)
        try await ascents.save(RidgelineFixtures.ascent(title: "Existing"))

        // When
        try await SimulatorTrailSeeder(
            routeRepository: routes,
            ascentRepository: ascents,
            gearRepository: gear
        ).seedIfEmpty()

        // Then
        let actual_6 = try await ascents.count()
        XCTAssertEqual(actual_6, 1)
    }
}
