import Foundation
@testable import Ridgeline

enum RidgelineFixtures {
    static func route(
        name: String = "Copper Ridge",
        distance: Double = 12.4,
        gain: Double = 860
    ) -> TrailRoute {
        TrailRoute(name: name, distanceKilometers: distance, elevationGainMeters: gain)
    }

    static func ascent(
        title: String = "Copper Ridge summit",
        routeID: UUID? = nil,
        distance: Double = 12.4,
        gain: Double = 860,
        duration: Double = 318,
        date: Date = Date()
    ) -> AscentLog {
        AscentLog(
            routeID: routeID,
            title: title,
            climbedAt: date,
            distanceKilometers: distance,
            elevationGainMeters: gain,
            durationMinutes: duration
        )
    }

    static func gear(title: String = "Microspikes", ascentID: UUID? = nil) -> GearNote {
        GearNote(ascentID: ascentID, title: title, detail: "Useful on scree.")
    }
}

final class InMemoryTrailRouteRepository: TrailRouteRepository, @unchecked Sendable {
    private var routes: [UUID: TrailRoute] = [:]
    private let lock = NSLock()

    func fetchAll() async throws -> [TrailRoute] {
        lock.withLock { Array(routes.values).sorted { $0.name < $1.name } }
    }

    func fetch(id: UUID) async throws -> TrailRoute? {
        lock.withLock { routes[id] }
    }

    func save(_ route: TrailRoute) async throws {
        lock.withLock { routes[route.id] = route }
    }

    func delete(id: UUID) async throws {
        lock.withLock { routes.removeValue(forKey: id) }
    }

    func count() async throws -> Int {
        lock.withLock { routes.count }
    }
}

final class InMemoryAscentLogRepository: AscentLogRepository, @unchecked Sendable {
    private var ascents: [UUID: AscentLog] = [:]
    private let lock = NSLock()

    func fetchAll() async throws -> [AscentLog] {
        lock.withLock { Array(ascents.values).sorted { $0.climbedAt > $1.climbedAt } }
    }

    func fetch(id: UUID) async throws -> AscentLog? {
        lock.withLock { ascents[id] }
    }

    func save(_ ascent: AscentLog) async throws {
        lock.withLock { ascents[ascent.id] = ascent }
    }

    func delete(id: UUID) async throws {
        lock.withLock { ascents.removeValue(forKey: id) }
    }

    func count() async throws -> Int {
        lock.withLock { ascents.count }
    }

    func removeAll() async throws {
        lock.withLock { ascents.removeAll() }
    }
}

final class InMemoryGearNoteRepository: GearNoteRepository, @unchecked Sendable {
    private var notes: [UUID: GearNote] = [:]
    private let lock = NSLock()

    func fetchAll() async throws -> [GearNote] {
        lock.withLock { Array(notes.values).sorted { $0.createdAt > $1.createdAt } }
    }

    func fetch(id: UUID) async throws -> GearNote? {
        lock.withLock { notes[id] }
    }

    func fetch(for ascentID: UUID) async throws -> [GearNote] {
        lock.withLock { notes.values.filter { $0.ascentID == ascentID } }
    }

    func save(_ note: GearNote) async throws {
        lock.withLock { notes[note.id] = note }
    }

    func delete(id: UUID) async throws {
        lock.withLock { notes.removeValue(forKey: id) }
    }

    func count() async throws -> Int {
        lock.withLock { notes.count }
    }
}

final class InMemoryOnboardingStore: OnboardingStore, @unchecked Sendable {
    private var completed = false
    private let lock = NSLock()

    func hasCompletedOnboarding() -> Bool {
        lock.withLock { completed }
    }

    func markOnboardingComplete() {
        lock.withLock { completed = true }
    }

    func resetOnboarding() {
        lock.withLock { completed = false }
    }
}

final class InMemoryPreferencesStore: PreferencesStore, @unchecked Sendable {
    private var preferences = Preferences.default
    private let lock = NSLock()

    func load() -> Preferences {
        lock.withLock { preferences }
    }

    func save(_ preferences: Preferences) {
        lock.withLock { self.preferences = preferences }
    }
}
