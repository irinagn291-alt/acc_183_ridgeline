import CoreData
import Foundation

enum TrailRouteMapping {
    static func route(from entity: TrailRouteEntity) -> TrailRoute {
        TrailRoute(
            id: entity.id,
            name: entity.name,
            distanceKilometers: entity.distanceKilometers,
            elevationGainMeters: entity.elevationGainMeters,
            createdAt: entity.createdAt
        )
    }

    static func apply(_ route: TrailRoute, to entity: TrailRouteEntity) {
        entity.id = route.id
        entity.name = route.name
        entity.distanceKilometers = route.distanceKilometers
        entity.elevationGainMeters = route.elevationGainMeters
        entity.createdAt = route.createdAt
    }
}

enum AscentLogMapping {
    static func ascent(from entity: AscentLogEntity) -> AscentLog {
        AscentLog(
            id: entity.id,
            routeID: entity.route?.id,
            title: entity.title,
            climbedAt: entity.climbedAt,
            distanceKilometers: entity.distanceKilometers,
            elevationGainMeters: entity.elevationGainMeters,
            durationMinutes: entity.durationMinutes,
            notes: entity.notes
        )
    }

    static func apply(_ ascent: AscentLog, to entity: AscentLogEntity, route: TrailRouteEntity?) {
        entity.id = ascent.id
        entity.title = ascent.title
        entity.climbedAt = ascent.climbedAt
        entity.distanceKilometers = ascent.distanceKilometers
        entity.elevationGainMeters = ascent.elevationGainMeters
        entity.durationMinutes = ascent.durationMinutes
        entity.notes = ascent.notes
        entity.route = route
    }
}

enum GearNoteMapping {
    static func note(from entity: GearNoteEntity) -> GearNote {
        GearNote(
            id: entity.id,
            ascentID: entity.ascent?.id,
            title: entity.title,
            detail: entity.detail,
            createdAt: entity.createdAt
        )
    }

    static func apply(_ note: GearNote, to entity: GearNoteEntity, ascent: AscentLogEntity?) {
        entity.id = note.id
        entity.title = note.title
        entity.detail = note.detail
        entity.createdAt = note.createdAt
        entity.ascent = ascent
    }
}
