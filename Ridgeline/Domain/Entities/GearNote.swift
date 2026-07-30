import Foundation

/// A gear remark tied to an ascent, or kept as a free-standing note.
public struct GearNote: Identifiable, Hashable, Sendable {
    public var id: UUID
    public var ascentID: UUID?
    public var title: String
    public var detail: String
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        ascentID: UUID? = nil,
        title: String,
        detail: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ascentID = ascentID
        self.title = title
        self.detail = detail
        self.createdAt = createdAt
    }
}
