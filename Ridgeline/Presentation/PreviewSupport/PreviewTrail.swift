import Foundation

/// Sample data helpers for SwiftUI previews.
@MainActor
enum PreviewTrail {
    static let sampleAscent = AscentLog(
        title: "Copper Ridge",
        distanceKilometers: 12.4,
        elevationGainMeters: 860,
        durationMinutes: 318,
        notes: "Clear contour lines."
    )

    static let sampleRoute = TrailRoute(
        name: "Copper Ridge",
        distanceKilometers: 12.4,
        elevationGainMeters: 860
    )

    static var seededContainer: RidgelineContainer {
        RidgelineContainer.preview()
    }
}
