import XCTest
@testable import Ridgeline

final class StatsUseCaseTests: XCTestCase {
    private var repository: InMemoryAscentLogRepository!

    override func setUp() async throws {
        repository = InMemoryAscentLogRepository()
        try await repository.save(RidgelineFixtures.ascent(
            title: "Short", distance: 5, gain: 300, duration: 90
        ))
        try await repository.save(RidgelineFixtures.ascent(
            title: "Long", distance: 18, gain: 900, duration: 420
        ))
        try await repository.save(RidgelineFixtures.ascent(
            title: "Mid", distance: 12, gain: 600, duration: 240
        ))
    }

    func test_givenAscents_whenComputingTotals_thenSumsMatch() async throws {
        // Given / When
        let totals = try await ComputeTotalGainUseCase(repository: repository)()

        // Then
        XCTAssertEqual(totals.ascentCount, 3)
        XCTAssertEqual(totals.totalGainMeters, 1800)
        XCTAssertEqual(totals.totalDistanceKilometers, 35)
    }

    func test_givenAscents_whenComputingPaceVsGrade_thenPointsExist() async throws {
        // Given / When
        let points = try await ComputePaceVsGradeUseCase(repository: repository)()

        // Then
        XCTAssertEqual(points.count, 3)
        XCTAssertTrue(points[0].gradePercent <= points[1].gradePercent)
    }

    func test_givenAscents_whenComputingDistanceDistribution_thenBucketsFill() async throws {
        // Given / When
        let buckets = try await ComputeDistanceDistributionUseCase(repository: repository)()

        // Then
        XCTAssertEqual(buckets.first { $0.label == "< 8 km" }?.count, 1)
        XCTAssertEqual(buckets.first { $0.label == "8–16 km" }?.count, 1)
        XCTAssertEqual(buckets.first { $0.label == "16+ km" }?.count, 1)
    }

    func test_givenAscents_whenComputingRecords_thenExtremesMatch() async throws {
        // Given / When
        let records = try await ComputePersonalRecordsUseCase(repository: repository)()

        // Then
        XCTAssertEqual(records.highestGainMeters, 900)
        XCTAssertEqual(records.longestDistanceKilometers, 18)
        XCTAssertEqual(records.fastestPaceMinutesPerKilometer, 18) // 90/5
    }

    func test_givenAscents_whenBuildingProfile_thenSamplesCoverUnitInterval() async throws {
        // Given / When
        let samples = try await BuildElevationProfileUseCase(repository: repository)(sampleCount: 12)

        // Then
        XCTAssertEqual(samples.count, 12)
        XCTAssertEqual(samples.first?.progress, 0)
        XCTAssertEqual(samples.last?.progress, 1)
    }

    func test_givenEmptyStore_whenBuildingInsights_thenEncouragementAppears() async throws {
        // Given
        let empty = InMemoryAscentLogRepository()
        let useCase = BuildRidgeInsightsUseCase(
            totals: ComputeTotalGainUseCase(repository: empty),
            records: ComputePersonalRecordsUseCase(repository: empty),
            paceGrade: ComputePaceVsGradeUseCase(repository: empty)
        )

        // When
        let insights = try await useCase()

        // Then
        XCTAssertEqual(insights.first?.kind, .encouragement)
    }

    func test_givenAscents_whenBuildingInsights_thenGainInsightPresent() async throws {
        // Given
        let useCase = BuildRidgeInsightsUseCase(
            totals: ComputeTotalGainUseCase(repository: repository),
            records: ComputePersonalRecordsUseCase(repository: repository),
            paceGrade: ComputePaceVsGradeUseCase(repository: repository)
        )

        // When
        let insights = try await useCase()

        // Then
        XCTAssertTrue(insights.contains { $0.kind == .gain })
    }
}
