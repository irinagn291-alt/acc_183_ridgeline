import Foundation

public struct ComputeTotalGainUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }

    public func callAsFunction() async throws -> RidgeTotals {
        let ascents = try await repository.fetchAll()
        let gain = ascents.reduce(0) { $0 + $1.elevationGainMeters }
        let distance = ascents.reduce(0) { $0 + $1.distanceKilometers }
        return RidgeTotals(
            totalGainMeters: gain,
            totalDistanceKilometers: distance,
            ascentCount: ascents.count
        )
    }
}

public struct ComputePaceVsGradeUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }

    public func callAsFunction() async throws -> [PaceGradePoint] {
        let ascents = try await repository.fetchAll()
        return ascents.compactMap { ascent in
            guard let pace = ascent.paceMinutesPerKilometer,
                  let grade = ascent.gradeFraction else { return nil }
            return PaceGradePoint(
                id: ascent.id,
                gradePercent: grade * 100,
                paceMinutesPerKilometer: pace,
                title: ascent.title
            )
        }
        .sorted { $0.gradePercent < $1.gradePercent }
    }
}

public struct ComputeDistanceDistributionUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }

    public func callAsFunction() async throws -> [DistanceBucket] {
        let ascents = try await repository.fetchAll()
        var short = 0
        var medium = 0
        var long = 0
        for ascent in ascents {
            switch ascent.distanceKilometers {
            case ..<8: short += 1
            case 8..<16: medium += 1
            default: long += 1
            }
        }
        return [
            DistanceBucket(label: "< 8 km", count: short),
            DistanceBucket(label: "8–16 km", count: medium),
            DistanceBucket(label: "16+ km", count: long)
        ]
    }
}

public struct ComputePersonalRecordsUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }

    public func callAsFunction() async throws -> PersonalRecords {
        let ascents = try await repository.fetchAll()
        guard !ascents.isEmpty else { return PersonalRecords() }
        let highest = ascents.map(\.elevationGainMeters).max()
        let longest = ascents.map(\.distanceKilometers).max()
        let fastest = ascents.compactMap(\.paceMinutesPerKilometer).min()
        let recent = ascents.max(by: { $0.climbedAt < $1.climbedAt })?.title
        return PersonalRecords(
            highestGainMeters: highest,
            longestDistanceKilometers: longest,
            fastestPaceMinutesPerKilometer: fastest,
            mostRecentTitle: recent
        )
    }
}

/// Builds a synthetic ridge profile from logged elevation totals.
public struct BuildElevationProfileUseCase: Sendable {
    private let repository: AscentLogRepository
    public init(repository: AscentLogRepository) { self.repository = repository }

    public func callAsFunction(sampleCount: Int = 24) async throws -> [ElevationSample] {
        let ascents = try await repository.fetchAll()
            .sorted { $0.climbedAt < $1.climbedAt }
        guard !ascents.isEmpty else {
            return Self.demoProfile(sampleCount: sampleCount)
        }
        var cumulative: [Double] = [0]
        for ascent in ascents {
            cumulative.append((cumulative.last ?? 0) + ascent.elevationGainMeters)
        }
        let peak = max(cumulative.max() ?? 1, 1)
        let count = max(sampleCount, 2)
        return (0..<count).map { index in
            let progress = Double(index) / Double(count - 1)
            let sourceIndex = progress * Double(cumulative.count - 1)
            let lower = Int(sourceIndex.rounded(.down))
            let upper = min(lower + 1, cumulative.count - 1)
            let t = sourceIndex - Double(lower)
            let elevation = cumulative[lower] * (1 - t) + cumulative[upper] * t
            // Gentle ridge shape: rise then soft descent after the cumulative peak.
            let ridgeShape = sin(progress * .pi)
            let normalized = (elevation / peak) * 0.55 + ridgeShape * 0.45
            return ElevationSample(id: index, progress: progress, elevationNormalized: min(normalized, 1))
        }
    }

    public static func demoProfile(sampleCount: Int = 24) -> [ElevationSample] {
        let count = max(sampleCount, 2)
        return (0..<count).map { index in
            let progress = Double(index) / Double(count - 1)
            let ridge = pow(sin(progress * .pi), 1.35)
            let foothill = 0.08 * sin(progress * .pi * 4)
            return ElevationSample(
                id: index,
                progress: progress,
                elevationNormalized: max(0, min(1, ridge * 0.9 + foothill))
            )
        }
    }
}
