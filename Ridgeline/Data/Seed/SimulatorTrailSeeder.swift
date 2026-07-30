import Foundation

/// Seeds sample climbs in the simulator when the journal is empty.
public struct SimulatorTrailSeeder: Sendable {
    private let routeRepository: TrailRouteRepository
    private let ascentRepository: AscentLogRepository
    private let gearRepository: GearNoteRepository

    public init(
        routeRepository: TrailRouteRepository,
        ascentRepository: AscentLogRepository,
        gearRepository: GearNoteRepository
    ) {
        self.routeRepository = routeRepository
        self.ascentRepository = ascentRepository
        self.gearRepository = gearRepository
    }

    public func seedIfEmpty() async throws {
        guard try await ascentRepository.count() == 0 else { return }

        let ridge = TrailRoute(
            name: "Copper Ridge",
            distanceKilometers: 12.4,
            elevationGainMeters: 860
        )
        let saddle = TrailRoute(
            name: "Saddle Contour",
            distanceKilometers: 7.2,
            elevationGainMeters: 420
        )
        let notch = TrailRoute(
            name: "Granite Notch",
            distanceKilometers: 15.8,
            elevationGainMeters: 1_120
        )
        try await routeRepository.save(ridge)
        try await routeRepository.save(saddle)
        try await routeRepository.save(notch)

        let calendar = Calendar.current
        let today = Date()
        let climbs: [AscentLog] = [
            AscentLog(
                routeID: ridge.id,
                title: "Copper Ridge summit",
                climbedAt: calendar.date(byAdding: .day, value: -12, to: today) ?? today,
                distanceKilometers: 12.4,
                elevationGainMeters: 860,
                durationMinutes: 318,
                notes: "Clear contour lines after the treeline."
            ),
            AscentLog(
                routeID: saddle.id,
                title: "Saddle Contour loop",
                climbedAt: calendar.date(byAdding: .day, value: -9, to: today) ?? today,
                distanceKilometers: 7.2,
                elevationGainMeters: 420,
                durationMinutes: 168,
                notes: "Steady grade, soft trail."
            ),
            AscentLog(
                routeID: notch.id,
                title: "Granite Notch traverse",
                climbedAt: calendar.date(byAdding: .day, value: -6, to: today) ?? today,
                distanceKilometers: 15.8,
                elevationGainMeters: 1_120,
                durationMinutes: 412,
                notes: "Wind on the ridge; turned for water at km 11."
            ),
            AscentLog(
                routeID: saddle.id,
                title: "Evening contour",
                climbedAt: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                distanceKilometers: 5.4,
                elevationGainMeters: 280,
                durationMinutes: 112,
                notes: "Short after-work climb."
            ),
            AscentLog(
                routeID: ridge.id,
                title: "Dawn push on Copper",
                climbedAt: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                distanceKilometers: 9.1,
                elevationGainMeters: 610,
                durationMinutes: 214,
                notes: "Turned around at the false summit."
            ),
            AscentLog(
                routeID: notch.id,
                title: "Notch training day",
                climbedAt: today,
                distanceKilometers: 8.6,
                elevationGainMeters: 540,
                durationMinutes: 196,
                notes: "Focus on pace vs grade."
            )
        ]
        for climb in climbs {
            try await ascentRepository.save(climb)
        }

        try await gearRepository.save(GearNote(
            ascentID: climbs[0].id,
            title: "Microspikes",
            detail: "Useful on the last 200 m of scree."
        ))
        try await gearRepository.save(GearNote(
            ascentID: climbs[2].id,
            title: "2L bladder",
            detail: "Refilled at the notch spring."
        ))
    }
}
