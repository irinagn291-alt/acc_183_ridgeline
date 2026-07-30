import Foundation

/// Dependency container: singleton scope for store/repos, per-request view models.
@MainActor
public final class RidgelineContainer {

    public let store: RidgelineDataStore
    public let routeRepository: TrailRouteRepository
    public let ascentRepository: AscentLogRepository
    public let gearRepository: GearNoteRepository
    public let onboardingStore: OnboardingStore
    public let preferencesStore: PreferencesStore

    public init(
        store: RidgelineDataStore,
        onboardingStore: OnboardingStore = UserDefaultsOnboardingStore(),
        preferencesStore: PreferencesStore = UserDefaultsPreferencesStore()
    ) {
        self.store = store
        self.routeRepository = CoreDataTrailRouteRepository(store: store)
        self.ascentRepository = CoreDataAscentLogRepository(store: store)
        self.gearRepository = CoreDataGearNoteRepository(store: store)
        self.onboardingStore = onboardingStore
        self.preferencesStore = preferencesStore
    }

    public static func preview() -> RidgelineContainer {
        let store = try! RidgelineDataStore(location: .inMemory)
        return RidgelineContainer(
            store: store,
            onboardingStore: UserDefaultsOnboardingStore(
                defaults: UserDefaults(suiteName: "com.ridgeline.ascent.preview") ?? .standard
            ),
            preferencesStore: UserDefaultsPreferencesStore(
                defaults: UserDefaults(suiteName: "com.ridgeline.ascent.preview.prefs") ?? .standard
            )
        )
    }

    // MARK: Use cases

    public var loadRoutes: LoadTrailRoutesUseCase { LoadTrailRoutesUseCase(repository: routeRepository) }
    public var createRoute: CreateTrailRouteUseCase { CreateTrailRouteUseCase(repository: routeRepository) }
    public var updateRoute: UpdateTrailRouteUseCase { UpdateTrailRouteUseCase(repository: routeRepository) }
    public var deleteRoute: DeleteTrailRouteUseCase { DeleteTrailRouteUseCase(repository: routeRepository) }

    public var loadAscents: LoadAscentsUseCase { LoadAscentsUseCase(repository: ascentRepository) }
    public var loadAscent: LoadAscentUseCase { LoadAscentUseCase(repository: ascentRepository) }
    public var createAscent: CreateAscentUseCase { CreateAscentUseCase(repository: ascentRepository) }
    public var updateAscent: UpdateAscentUseCase { UpdateAscentUseCase(repository: ascentRepository) }
    public var deleteAscent: DeleteAscentUseCase { DeleteAscentUseCase(repository: ascentRepository) }
    public var journalIsEmpty: JournalIsEmptyUseCase { JournalIsEmptyUseCase(repository: ascentRepository) }

    public var loadGearNotes: LoadGearNotesUseCase { LoadGearNotesUseCase(repository: gearRepository) }
    public var createGearNote: CreateGearNoteUseCase { CreateGearNoteUseCase(repository: gearRepository) }
    public var updateGearNote: UpdateGearNoteUseCase { UpdateGearNoteUseCase(repository: gearRepository) }
    public var deleteGearNote: DeleteGearNoteUseCase { DeleteGearNoteUseCase(repository: gearRepository) }

    public var computeTotals: ComputeTotalGainUseCase { ComputeTotalGainUseCase(repository: ascentRepository) }
    public var computePaceGrade: ComputePaceVsGradeUseCase { ComputePaceVsGradeUseCase(repository: ascentRepository) }
    public var computeDistanceDistribution: ComputeDistanceDistributionUseCase {
        ComputeDistanceDistributionUseCase(repository: ascentRepository)
    }
    public var computeRecords: ComputePersonalRecordsUseCase {
        ComputePersonalRecordsUseCase(repository: ascentRepository)
    }
    public var buildProfile: BuildElevationProfileUseCase {
        BuildElevationProfileUseCase(repository: ascentRepository)
    }
    public var buildInsights: BuildRidgeInsightsUseCase {
        BuildRidgeInsightsUseCase(totals: computeTotals, records: computeRecords, paceGrade: computePaceGrade)
    }
    public var resetData: ResetRidgelineDataUseCase {
        ResetRidgelineDataUseCase(
            ascentRepository: ascentRepository,
            routeRepository: routeRepository,
            gearRepository: gearRepository,
            onboardingStore: onboardingStore
        )
    }
    public var loadPreferences: LoadPreferencesUseCase { LoadPreferencesUseCase(store: preferencesStore) }
    public var savePreferences: SavePreferencesUseCase { SavePreferencesUseCase(store: preferencesStore) }

    // MARK: View models

    public func makeDashboardViewModel() -> ProfileDashboardViewModel {
        ProfileDashboardViewModel(
            loadAscents: loadAscents,
            computeTotals: computeTotals,
            buildProfile: buildProfile,
            loadPreferences: loadPreferences
        )
    }

    public func makeOnboardingViewModel() -> OnboardingAscentViewModel {
        OnboardingAscentViewModel(
            createAscent: createAscent,
            createRoute: createRoute,
            onboardingStore: onboardingStore
        )
    }

    public func makeAscentEditorViewModel(ascentID: UUID? = nil) -> AscentEditorViewModel {
        AscentEditorViewModel(
            ascentID: ascentID,
            loadAscent: loadAscent,
            createAscent: createAscent,
            updateAscent: updateAscent,
            createGearNote: createGearNote,
            loadRoutes: loadRoutes
        )
    }

    public func makeChartsViewModel() -> RidgeChartsViewModel {
        RidgeChartsViewModel(
            computeTotals: computeTotals,
            computePaceGrade: computePaceGrade,
            computeDistanceDistribution: computeDistanceDistribution,
            computeRecords: computeRecords
        )
    }

    public func makeInsightsViewModel() -> RidgeInsightsViewModel {
        RidgeInsightsViewModel(buildInsights: buildInsights)
    }

    public func makeHistoryViewModel() -> AscentHistoryViewModel {
        AscentHistoryViewModel(loadAscents: loadAscents, deleteAscent: deleteAscent)
    }

    public func makeSettingsViewModel() -> RidgeSettingsViewModel {
        RidgeSettingsViewModel(
            loadPreferences: loadPreferences,
            savePreferences: savePreferences,
            resetData: resetData
        )
    }
}
