import CoreData
import Foundation

public final class CoreDataAscentLogRepository: AscentLogRepository {
    private let store: RidgelineDataStore

    public init(store: RidgelineDataStore) {
        self.store = store
    }

    public func fetchAll() async throws -> [AscentLog] {
        try await store.perform { context in
            let request = NSFetchRequest<AscentLogEntity>(entityName: RidgelineEntityName.ascentLog)
            request.sortDescriptors = [NSSortDescriptor(key: "climbedAt", ascending: false)]
            return try context.fetch(request).map(AscentLogMapping.ascent(from:))
        }
    }

    public func fetch(id: UUID) async throws -> AscentLog? {
        try await store.perform { context in
            try Self.row(id: id, in: context).map(AscentLogMapping.ascent(from:))
        }
    }

    public func save(_ ascent: AscentLog) async throws {
        try await store.perform { context in
            let entity = try Self.row(id: ascent.id, in: context) ?? AscentLogEntity(context: context)
            let route: TrailRouteEntity?
            if let routeID = ascent.routeID {
                route = try Self.route(id: routeID, in: context)
            } else {
                route = nil
            }
            AscentLogMapping.apply(ascent, to: entity, route: route)
            try Self.commit(context)
        }
    }

    public func delete(id: UUID) async throws {
        try await store.perform { context in
            guard let entity = try Self.row(id: id, in: context) else { return }
            context.delete(entity)
            try Self.commit(context)
        }
    }

    public func count() async throws -> Int {
        try await store.perform { context in
            let request = NSFetchRequest<AscentLogEntity>(entityName: RidgelineEntityName.ascentLog)
            return try context.count(for: request)
        }
    }

    public func removeAll() async throws {
        try await store.perform { context in
            let request = NSFetchRequest<AscentLogEntity>(entityName: RidgelineEntityName.ascentLog)
            for entity in try context.fetch(request) {
                context.delete(entity)
            }
            try Self.commit(context)
        }
    }

    private static func row(id: UUID, in context: NSManagedObjectContext) throws -> AscentLogEntity? {
        let request = NSFetchRequest<AscentLogEntity>(entityName: RidgelineEntityName.ascentLog)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private static func route(id: UUID, in context: NSManagedObjectContext) throws -> TrailRouteEntity? {
        let request = NSFetchRequest<TrailRouteEntity>(entityName: RidgelineEntityName.trailRoute)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private static func commit(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw RidgelineError.storeFailure(error.localizedDescription)
        }
    }
}
