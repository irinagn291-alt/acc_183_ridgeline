import SwiftUI

/// Application entry point for Ridgeline.
@main
struct RidgelineApp: App {
    private let container: RidgelineContainer?
    private let startupError: String?

    init() {
        do {
            container = RidgelineContainer(store: try RidgelineDataStore())
            startupError = nil
        } catch {
            container = nil
            startupError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container {
                RootView(container: container)
            } else {
                RidgeEmptyState(
                    title: "Unavailable",
                    detail: startupError ?? "The store could not be opened."
                )
                .ridgeGround()
            }
        }
    }
}
