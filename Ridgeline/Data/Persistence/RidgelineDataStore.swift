import CoreData
import Foundation

/// Owns the persistent container and hands out scoped access to a private
/// context.
///
/// Marked `@unchecked Sendable` on purpose. `NSPersistentContainer` is not
/// `Sendable`, but the only context this type exposes is a private-queue context
/// reached exclusively through ``perform(_:)``, and no managed object ever
/// escapes that closure.
public final class RidgelineDataStore: @unchecked Sendable {

    /// A recoverable copy of a store that could not be opened.
    public struct Recovery: Sendable {
        /// Directory containing the quarantined store files.
        public let directory: URL
    }

    /// Where the store lives.
    public enum Location: Sendable {
        /// The app's default on-disk store.
        case onDisk
        /// A throwaway store, used by tests and by SwiftUI previews.
        case inMemory
    }

    /// The model is built once per process. Core Data warns when two model
    /// instances claim the same managed object classes, and previews plus tests
    /// happily open several stores inside one process.
    ///
    /// `nonisolated(unsafe)` because `NSManagedObjectModel` is not `Sendable`. It is
    /// safe here: the model is built once during static initialisation and only ever
    /// read afterwards, and Core Data itself treats a loaded model as immutable.
    nonisolated(unsafe) private static let sharedModel: NSManagedObjectModel =
        RidgelineModelBuilder.makeModel()

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    /// Opens a store.
    ///
    /// Throws ``RidgelineError/storeFailure(_:)`` when the persistent store cannot
    /// be loaded, so the app can surface a real message instead of trapping.
    public init(location: Location = .onDisk, name: String = "RidgelineJournal") throws {
        container = NSPersistentContainer(name: name, managedObjectModel: Self.sharedModel)

        let description: NSPersistentStoreDescription
        switch location {
        case .inMemory:
            description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
        case .onDisk:
            description = container.persistentStoreDescriptions[0]
        }
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            if let error { loadError = error }
        }
        if let loadError {
            throw RidgelineError.storeFailure(loadError.localizedDescription)
        }

        context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        context.automaticallyMergesChangesFromParent = true
    }

    /// Moves an unreadable on-disk store aside for support or forensic recovery.
    @discardableResult
    public static func quarantineCorruptedStore(
        named name: String = "RidgelineJournal",
        fileManager: FileManager = .default
    ) throws -> Recovery? {
        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appending(path: name)
            .appendingPathExtension("sqlite")
        let relatedURLs = [
            storeURL,
            URL(fileURLWithPath: "\(storeURL.path)-wal"),
            URL(fileURLWithPath: "\(storeURL.path)-shm")
        ]
        let existingURLs = relatedURLs.filter { fileManager.fileExists(atPath: $0.path) }
        guard !existingURLs.isEmpty else { return nil }

        let recoveryDirectory = NSPersistentContainer.defaultDirectoryURL()
            .appending(path: "Recovered Stores")
            .appending(path: "\(name)-\(ISO8601DateFormatter().string(from: Date()))")
        try fileManager.createDirectory(at: recoveryDirectory, withIntermediateDirectories: true)

        do {
            for sourceURL in existingURLs {
                try fileManager.moveItem(
                    at: sourceURL,
                    to: recoveryDirectory.appending(path: sourceURL.lastPathComponent)
                )
            }
        } catch {
            try? fileManager.removeItem(at: recoveryDirectory)
            throw error
        }

        return Recovery(directory: recoveryDirectory)
    }

    /// Removes every ascent, route and gear note from the open store.
    public func removeAllRecords() async throws {
        try await perform { context in
            for entityName in [
                RidgelineEntityName.gearNote,
                RidgelineEntityName.ascentLog,
                RidgelineEntityName.trailRoute
            ] {
                let request = NSBatchDeleteRequest(
                    fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                )
                request.resultType = .resultTypeStatusOnly
                try context.execute(request)
            }
            try context.save()
        }
    }

    /// Runs work on the store's private queue and returns a value type.
    ///
    /// The generic is constrained to `Sendable` so the compiler enforces the rule
    /// that managed objects never leave the closure.
    ///
    /// Marked `@concurrent` so that, under `NonisolatedNonsendingByDefault`, this
    /// method leaves the caller's actor before scheduling Core Data work. Without
    /// that hop, `context.perform` would invoke a `@MainActor`-isolated closure on
    /// its private queue and trap (`swift_task_checkIsolatedSwift`).
    @concurrent
    public func perform<T: Sendable>(
        _ body: @escaping @Sendable (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        let context = self.context
        return try await withCheckedThrowingContinuation { continuation in
            context.perform { @Sendable in
                do {
                    continuation.resume(returning: try body(context))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
