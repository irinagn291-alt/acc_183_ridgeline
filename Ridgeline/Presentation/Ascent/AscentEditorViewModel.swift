import Foundation
import Observation

@Observable
@MainActor
public final class AscentEditorViewModel {
    public let ascentID: UUID?
    public var title: String = ""
    public var distanceText: String = ""
    public var gainText: String = ""
    public var durationText: String = ""
    public var notes: String = ""
    public var gearTitle: String = ""
    public var gearDetail: String = ""
    public var climbedAt: Date = Date()
    public var selectedRouteID: UUID?
    public private(set) var routes: [TrailRoute] = []
    public private(set) var isSaving = false
    public var errorMessage: String?

    public var isEditing: Bool { ascentID != nil }

    private let loadAscent: LoadAscentUseCase
    private let createAscent: CreateAscentUseCase
    private let updateAscent: UpdateAscentUseCase
    private let createGearNote: CreateGearNoteUseCase
    private let loadRoutes: LoadTrailRoutesUseCase

    public init(
        ascentID: UUID?,
        loadAscent: LoadAscentUseCase,
        createAscent: CreateAscentUseCase,
        updateAscent: UpdateAscentUseCase,
        createGearNote: CreateGearNoteUseCase,
        loadRoutes: LoadTrailRoutesUseCase
    ) {
        self.ascentID = ascentID
        self.loadAscent = loadAscent
        self.createAscent = createAscent
        self.updateAscent = updateAscent
        self.createGearNote = createGearNote
        self.loadRoutes = loadRoutes
    }

    public func load() async {
        do {
            routes = try await loadRoutes()
            if let ascentID {
                let ascent = try await loadAscent(id: ascentID)
                title = ascent.title
                distanceText = String(format: "%.1f", ascent.distanceKilometers)
                gainText = String(format: "%.0f", ascent.elevationGainMeters)
                durationText = String(format: "%.0f", ascent.durationMinutes)
                notes = ascent.notes
                climbedAt = ascent.climbedAt
                selectedRouteID = ascent.routeID
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func save() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        guard let distance = Double(distanceText),
              let gain = Double(gainText),
              let duration = Double(durationText) else {
            errorMessage = RidgelineError.invalidMeasurement.localizedDescription
            return false
        }
        do {
            let saved: AscentLog
            if let ascentID {
                var ascent = try await loadAscent(id: ascentID)
                ascent.title = title
                ascent.distanceKilometers = distance
                ascent.elevationGainMeters = gain
                ascent.durationMinutes = duration
                ascent.notes = notes
                ascent.climbedAt = climbedAt
                ascent.routeID = selectedRouteID
                saved = try await updateAscent(ascent)
            } else {
                saved = try await createAscent(
                    title: title,
                    routeID: selectedRouteID,
                    climbedAt: climbedAt,
                    distanceKilometers: distance,
                    elevationGainMeters: gain,
                    durationMinutes: duration,
                    notes: notes
                )
            }
            let gear = gearTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if !gear.isEmpty {
                _ = try await createGearNote(
                    title: gear,
                    detail: gearDetail,
                    ascentID: saved.id,
                    now: Date()
                )
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
