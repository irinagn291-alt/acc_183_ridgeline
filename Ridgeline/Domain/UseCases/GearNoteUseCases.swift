import Foundation

public struct LoadGearNotesUseCase: Sendable {
    private let repository: GearNoteRepository
    public init(repository: GearNoteRepository) { self.repository = repository }
    public func callAsFunction() async throws -> [GearNote] {
        try await repository.fetchAll()
    }
}

public struct LoadGearNotesForAscentUseCase: Sendable {
    private let repository: GearNoteRepository
    public init(repository: GearNoteRepository) { self.repository = repository }
    public func callAsFunction(ascentID: UUID) async throws -> [GearNote] {
        try await repository.fetch(for: ascentID)
    }
}

public struct CreateGearNoteUseCase: Sendable {
    private let repository: GearNoteRepository
    public init(repository: GearNoteRepository) { self.repository = repository }
    public func callAsFunction(
        title: String,
        detail: String = "",
        ascentID: UUID? = nil,
        now: Date = Date()
    ) async throws -> GearNote {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw RidgelineError.blankName }
        let note = GearNote(ascentID: ascentID, title: trimmed, detail: detail, createdAt: now)
        try await repository.save(note)
        return note
    }
}

public struct UpdateGearNoteUseCase: Sendable {
    private let repository: GearNoteRepository
    public init(repository: GearNoteRepository) { self.repository = repository }
    public func callAsFunction(_ note: GearNote) async throws -> GearNote {
        guard !note.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RidgelineError.blankName
        }
        try await repository.save(note)
        return note
    }
}

public struct DeleteGearNoteUseCase: Sendable {
    private let repository: GearNoteRepository
    public init(repository: GearNoteRepository) { self.repository = repository }
    public func callAsFunction(id: UUID) async throws {
        guard try await repository.fetch(id: id) != nil else {
            throw RidgelineError.gearNoteNotFound(id)
        }
        try await repository.delete(id: id)
    }
}
