import Foundation
import Observation

@Observable
@MainActor
public final class RidgeInsightsViewModel {
    public private(set) var insights: [RidgeInsight] = []
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let buildInsights: BuildRidgeInsightsUseCase

    public init(buildInsights: BuildRidgeInsightsUseCase) {
        self.buildInsights = buildInsights
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            insights = try await buildInsights()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
