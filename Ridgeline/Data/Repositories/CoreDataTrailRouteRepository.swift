import CoreData
import Foundation

public final class CoreDataTrailRouteRepository: TrailRouteRepository {
    private let store: RidgelineDataStore

    public init(store: RidgelineDataStore) {
        self.store = store
    }

    public func fetchAll() async throws -> [TrailRoute] {
        try await store.perform { context in
            let request = NSFetchRequest<TrailRouteEntity>(entityName: RidgelineEntityName.trailRoute)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).map(TrailRouteMapping.route(from:))
        }
    }

    public func fetch(id: UUID) async throws -> TrailRoute? {
        try await store.perform { context in
            try Self.row(id: id, in: context).map(TrailRouteMapping.route(from:))
        }
    }

    public func save(_ route: TrailRoute) async throws {
        try await store.perform { context in
            let entity = try Self.row(id: route.id, in: context) ?? TrailRouteEntity(context: context)
            TrailRouteMapping.apply(route, to: entity)
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
            let request = NSFetchRequest<TrailRouteEntity>(entityName: RidgelineEntityName.trailRoute)
            return try context.count(for: request)
        }
    }

    private static func row(id: UUID, in context: NSManagedObjectContext) throws -> TrailRouteEntity? {
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
