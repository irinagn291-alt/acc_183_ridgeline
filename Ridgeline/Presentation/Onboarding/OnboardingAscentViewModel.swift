import Foundation
import Observation

/// Two-step demo-first onboarding: enter a climb, then watch the profile draw.
@Observable
@MainActor
public final class OnboardingAscentViewModel {
    public var step: Int = 0
    public var title: String = ""
    public var distanceText: String = "10"
    public var gainText: String = "650"
    public var durationText: String = "240"
    public var isSaving = false
    public var errorMessage: String?
    public private(set) var savedAscent: AscentLog?
    public private(set) var profileSamples: [ElevationSample] = BuildElevationProfileUseCase.demoProfile()

    private let createAscent: CreateAscentUseCase
    private let createRoute: CreateTrailRouteUseCase
    private let onboardingStore: OnboardingStore

    public init(
        createAscent: CreateAscentUseCase,
        createRoute: CreateTrailRouteUseCase,
        onboardingStore: OnboardingStore
    ) {
        self.createAscent = createAscent
        self.createRoute = createRoute
        self.onboardingStore = onboardingStore
    }

    public func continueFromEntry() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        errorMessage = nil
        guard let distance = Double(distanceText),
              let gain = Double(gainText),
              let duration = Double(durationText) else {
            errorMessage = RidgelineError.invalidMeasurement.localizedDescription
            return false
        }
        let climbTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle = climbTitle.isEmpty ? "First summit" : climbTitle
        do {
            let route = try await createRoute(
                name: resolvedTitle,
                distanceKilometers: distance,
                elevationGainMeters: gain
            )
            let ascent = try await createAscent(
                title: resolvedTitle,
                routeID: route.id,
                climbedAt: Date(),
                distanceKilometers: distance,
                elevationGainMeters: gain,
                durationMinutes: duration,
                notes: "Logged during onboarding."
            )
            savedAscent = ascent
            profileSamples = BuildElevationProfileUseCase.demoProfile()
            // Bias the demo ridge toward the entered gain so the draw feels personal.
            let scale = min(1, gain / 1_200)
            profileSamples = profileSamples.map { sample in
                ElevationSample(
                    id: sample.id,
                    progress: sample.progress,
                    elevationNormalized: min(1, sample.elevationNormalized * (0.55 + scale * 0.45))
                )
            }
            step = 1
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    public func finish() {
        onboardingStore.markOnboardingComplete()
    }
}
