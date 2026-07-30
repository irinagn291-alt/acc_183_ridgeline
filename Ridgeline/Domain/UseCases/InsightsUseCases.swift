import Foundation

public struct BuildRidgeInsightsUseCase: Sendable {
    private let totals: ComputeTotalGainUseCase
    private let records: ComputePersonalRecordsUseCase
    private let paceGrade: ComputePaceVsGradeUseCase

    public init(
        totals: ComputeTotalGainUseCase,
        records: ComputePersonalRecordsUseCase,
        paceGrade: ComputePaceVsGradeUseCase
    ) {
        self.totals = totals
        self.records = records
        self.paceGrade = paceGrade
    }

    public func callAsFunction() async throws -> [RidgeInsight] {
        let summary = try await totals()
        var insights: [RidgeInsight] = []

        if summary.ascentCount == 0 {
            return [
                RidgeInsight(
                    kind: .encouragement,
                    title: "First contour awaits",
                    detail: "Log an ascent and the ridge profile will draw itself."
                )
            ]
        }

        let gainText = String(format: "%.0f m", summary.totalGainMeters)
        insights.append(RidgeInsight(
            kind: .gain,
            title: "\(gainText) total gain",
            detail: "Across \(summary.ascentCount) logged ascent\(summary.ascentCount == 1 ? "" : "s")."
        ))

        let personal = try await records()
        if let fastest = personal.fastestPaceMinutesPerKilometer {
            insights.append(RidgeInsight(
                kind: .pace,
                title: String(format: "Best pace %.1f min/km", fastest),
                detail: "Your quickest average across recorded climbs."
            ))
        }

        if let longest = personal.longestDistanceKilometers {
            insights.append(RidgeInsight(
                kind: .distance,
                title: String(format: "Longest day %.1f km", longest),
                detail: personal.mostRecentTitle.map { "Most recent climb: \($0)." }
                    ?? "Keep stretching the ridge."
            ))
        }

        let points = try await paceGrade()
        if let steepest = points.max(by: { $0.gradePercent < $1.gradePercent }),
           steepest.gradePercent >= 5 {
            insights.append(RidgeInsight(
                kind: .pace,
                title: String(format: "Steepest grade %.0f%%", steepest.gradePercent),
                detail: "\(steepest.title) pushed the contour lines hardest."
            ))
        }

        return insights
    }
}

public struct ResetRidgelineDataUseCase: Sendable {
    private let ascentRepository: AscentLogRepository
    private let routeRepository: TrailRouteRepository
    private let gearRepository: GearNoteRepository
    private let onboardingStore: OnboardingStore

    public init(
        ascentRepository: AscentLogRepository,
        routeRepository: TrailRouteRepository,
        gearRepository: GearNoteRepository,
        onboardingStore: OnboardingStore
    ) {
        self.ascentRepository = ascentRepository
        self.routeRepository = routeRepository
        self.gearRepository = gearRepository
        self.onboardingStore = onboardingStore
    }

    public func callAsFunction() async throws {
        try await ascentRepository.removeAll()
        let routes = try await routeRepository.fetchAll()
        for route in routes {
            try await routeRepository.delete(id: route.id)
        }
        let notes = try await gearRepository.fetchAll()
        for note in notes {
            try await gearRepository.delete(id: note.id)
        }
        onboardingStore.resetOnboarding()
    }
}

public struct LoadPreferencesUseCase: Sendable {
    private let store: PreferencesStore
    public init(store: PreferencesStore) { self.store = store }
    public func callAsFunction() -> Preferences { store.load() }
}

public struct SavePreferencesUseCase: Sendable {
    private let store: PreferencesStore
    public init(store: PreferencesStore) { self.store = store }
    public func callAsFunction(_ preferences: Preferences) { store.save(preferences) }
}
