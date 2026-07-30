import Observation
import SwiftUI

/// Everywhere the app can go past the dashboard.
public enum RidgelineRoute: Hashable, Sendable {
    case charts
    case insights
    case history
    case settings
    case gallery
    case editAscent(UUID)
}

/// Which sheet, if any, is presented over the current screen.
public enum RidgelineSheet: Hashable, Sendable, Identifiable {
    case logAscent
    case editAscent(UUID)

    public var id: String {
        switch self {
        case .logAscent: return "logAscent"
        case .editAscent(let id): return "editAscent-\(id.uuidString)"
        }
    }
}

/// Owns the navigation stack and the presented sheet.
@Observable
@MainActor
public final class RidgelineCoordinator {

    public var path: [RidgelineRoute] = []
    public var sheet: RidgelineSheet?

    public init() {}

    public func openCharts() { path.append(.charts) }
    public func openInsights() { path.append(.insights) }
    public func openHistory() { path.append(.history) }
    public func openSettings() { path.append(.settings) }
    public func openGallery() { path.append(.gallery) }
    public func openEditAscent(_ id: UUID) { path.append(.editAscent(id)) }

    public func presentLogAscent() { sheet = .logAscent }
    public func presentEditAscent(_ id: UUID) { sheet = .editAscent(id) }
    public func dismissSheet() { sheet = nil }

    public func popToRoot() { path.removeAll() }
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
