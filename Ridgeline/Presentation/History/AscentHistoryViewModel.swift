import Foundation
import Observation

@Observable
@MainActor
public final class AscentHistoryViewModel {
    public private(set) var ascents: [AscentLog] = []
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let loadAscents: LoadAscentsUseCase
    private let deleteAscent: DeleteAscentUseCase

    public init(loadAscents: LoadAscentsUseCase, deleteAscent: DeleteAscentUseCase) {
        self.loadAscents = loadAscents
        self.deleteAscent = deleteAscent
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            ascents = try await loadAscents()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func delete(_ ascent: AscentLog) async {
        do {
            try await deleteAscent(id: ascent.id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
