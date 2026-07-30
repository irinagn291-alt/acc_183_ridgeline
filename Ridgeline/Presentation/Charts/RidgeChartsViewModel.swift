import Foundation
import Observation

@Observable
@MainActor
public final class RidgeChartsViewModel {
    public private(set) var totals: RidgeTotals = RidgeTotals(
        totalGainMeters: 0,
        totalDistanceKilometers: 0,
        ascentCount: 0
    )
    public private(set) var paceGrade: [PaceGradePoint] = []
    public private(set) var distanceBuckets: [DistanceBucket] = []
    public private(set) var records: PersonalRecords = PersonalRecords()
    public private(set) var isLoading = false
    public var errorMessage: String?

    private let computeTotals: ComputeTotalGainUseCase
    private let computePaceGrade: ComputePaceVsGradeUseCase
    private let computeDistanceDistribution: ComputeDistanceDistributionUseCase
    private let computeRecords: ComputePersonalRecordsUseCase

    public init(
        computeTotals: ComputeTotalGainUseCase,
        computePaceGrade: ComputePaceVsGradeUseCase,
        computeDistanceDistribution: ComputeDistanceDistributionUseCase,
        computeRecords: ComputePersonalRecordsUseCase
    ) {
        self.computeTotals = computeTotals
        self.computePaceGrade = computePaceGrade
        self.computeDistanceDistribution = computeDistanceDistribution
        self.computeRecords = computeRecords
    }

    public func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            totals = try await computeTotals()
            paceGrade = try await computePaceGrade()
            distanceBuckets = try await computeDistanceDistribution()
            records = try await computeRecords()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
