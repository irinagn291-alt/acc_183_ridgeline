import CoreData
import Foundation

public final class CoreDataGearNoteRepository: GearNoteRepository {
    private let store: RidgelineDataStore

    public init(store: RidgelineDataStore) {
        self.store = store
    }

    public func fetchAll() async throws -> [GearNote] {
        try await store.perform { context in
            let request = NSFetchRequest<GearNoteEntity>(entityName: RidgelineEntityName.gearNote)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).map(GearNoteMapping.note(from:))
        }
    }

    public func fetch(id: UUID) async throws -> GearNote? {
        try await store.perform { context in
            try Self.row(id: id, in: context).map(GearNoteMapping.note(from:))
        }
    }

    public func fetch(for ascentID: UUID) async throws -> [GearNote] {
        try await store.perform { context in
            let request = NSFetchRequest<GearNoteEntity>(entityName: RidgelineEntityName.gearNote)
            request.predicate = NSPredicate(format: "ascent.id == %@", ascentID as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request).map(GearNoteMapping.note(from:))
        }
    }

    public func save(_ note: GearNote) async throws {
        try await store.perform { context in
            let entity = try Self.row(id: note.id, in: context) ?? GearNoteEntity(context: context)
            let ascent: AscentLogEntity?
            if let ascentID = note.ascentID {
                ascent = try Self.ascent(id: ascentID, in: context)
            } else {
                ascent = nil
            }
            GearNoteMapping.apply(note, to: entity, ascent: ascent)
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
            let request = NSFetchRequest<GearNoteEntity>(entityName: RidgelineEntityName.gearNote)
            return try context.count(for: request)
        }
    }

    private static func row(id: UUID, in context: NSManagedObjectContext) throws -> GearNoteEntity? {
        let request = NSFetchRequest<GearNoteEntity>(entityName: RidgelineEntityName.gearNote)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    private static func ascent(id: UUID, in context: NSManagedObjectContext) throws -> AscentLogEntity? {
        let request = NSFetchRequest<AscentLogEntity>(entityName: RidgelineEntityName.ascentLog)
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
