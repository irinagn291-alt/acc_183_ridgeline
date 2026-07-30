import CoreData
import Foundation

/// Assembles the Core Data model in code.
public enum RidgelineModelBuilder {

    public static func makeModel() -> NSManagedObjectModel {
        let route = NSEntityDescription()
        route.name = RidgelineEntityName.trailRoute
        route.managedObjectClassName = NSStringFromClass(TrailRouteEntity.self)

        let ascent = NSEntityDescription()
        ascent.name = RidgelineEntityName.ascentLog
        ascent.managedObjectClassName = NSStringFromClass(AscentLogEntity.self)

        let gear = NSEntityDescription()
        gear.name = RidgelineEntityName.gearNote
        gear.managedObjectClassName = NSStringFromClass(GearNoteEntity.self)

        route.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("name", .stringAttributeType),
            attribute("distanceKilometers", .doubleAttributeType),
            attribute("elevationGainMeters", .doubleAttributeType),
            attribute("createdAt", .dateAttributeType)
        ]
        ascent.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("title", .stringAttributeType),
            attribute("climbedAt", .dateAttributeType),
            attribute("distanceKilometers", .doubleAttributeType),
            attribute("elevationGainMeters", .doubleAttributeType),
            attribute("durationMinutes", .doubleAttributeType),
            attribute("notes", .stringAttributeType)
        ]
        gear.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("title", .stringAttributeType),
            attribute("detail", .stringAttributeType),
            attribute("createdAt", .dateAttributeType)
        ]

        link(parent: route, childName: "ascents", child: ascent, inverseName: "route")
        link(parent: ascent, childName: "gearNotes", child: gear, inverseName: "ascent")

        route.uniquenessConstraints = [["id"]]
        ascent.uniquenessConstraints = [["id"]]
        gear.uniquenessConstraints = [["id"]]

        let model = NSManagedObjectModel()
        model.entities = [route, ascent, gear]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false
    ) -> NSAttributeDescription {
        let description = NSAttributeDescription()
        description.name = name
        description.attributeType = type
        description.isOptional = optional
        return description
    }

    private static func link(
        parent: NSEntityDescription,
        childName: String,
        child: NSEntityDescription,
        inverseName: String
    ) {
        let toMany = NSRelationshipDescription()
        toMany.name = childName
        toMany.destinationEntity = child
        toMany.minCount = 0
        toMany.maxCount = 0
        toMany.deleteRule = .cascadeDeleteRule
        toMany.isOptional = true

        let toOne = NSRelationshipDescription()
        toOne.name = inverseName
        toOne.destinationEntity = parent
        toOne.minCount = 0
        toOne.maxCount = 1
        toOne.deleteRule = .nullifyDeleteRule
        toOne.isOptional = true

        toMany.inverseRelationship = toOne
        toOne.inverseRelationship = toMany

        parent.properties.append(toMany)
        child.properties.append(toOne)
    }
}
