import Foundation

/// Every failure the domain layer can report.
public enum RidgelineError: LocalizedError, Equatable, Sendable {
    case routeNotFound(UUID)
    case ascentNotFound(UUID)
    case gearNoteNotFound(UUID)
    case blankName
    case invalidMeasurement
    case storeFailure(String)

    public var errorDescription: String? {
        switch self {
        case .routeNotFound:
            return "That trail is no longer on the map."
        case .ascentNotFound:
            return "That ascent could not be found."
        case .gearNoteNotFound:
            return "That gear note could not be found."
        case .blankName:
            return "A name is required."
        case .invalidMeasurement:
            return "Distance, gain and duration must be positive."
        case .storeFailure(let detail):
            return "The journal could not be saved. \(detail)"
        }
    }
}
