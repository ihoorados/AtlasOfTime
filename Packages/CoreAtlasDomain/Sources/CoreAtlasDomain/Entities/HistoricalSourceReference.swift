import Foundation

public struct HistoricalSourceReference: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public let title: String
    public let locator: String?
    public let url: URL?
    public let note: String?

    public init(
        id: String,
        title: String,
        locator: String? = nil,
        url: URL? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.title = title
        self.locator = locator
        self.url = url
        self.note = note
    }
}
