import CoreData
import Foundation

@objc(TrailRouteEntity)
public final class TrailRouteEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var distanceKilometers: Double
    @NSManaged public var elevationGainMeters: Double
    @NSManaged public var createdAt: Date
    @NSManaged public var ascents: NSSet?
}

@objc(AscentLogEntity)
public final class AscentLogEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var climbedAt: Date
    @NSManaged public var distanceKilometers: Double
    @NSManaged public var elevationGainMeters: Double
    @NSManaged public var durationMinutes: Double
    @NSManaged public var notes: String
    @NSManaged public var route: TrailRouteEntity?
    @NSManaged public var gearNotes: NSSet?
}

@objc(GearNoteEntity)
public final class GearNoteEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var detail: String
    @NSManaged public var createdAt: Date
    @NSManaged public var ascent: AscentLogEntity?
}

public enum RidgelineEntityName {
    public static let trailRoute = "TrailRouteEntity"
    public static let ascentLog = "AscentLogEntity"
    public static let gearNote = "GearNoteEntity"
}
