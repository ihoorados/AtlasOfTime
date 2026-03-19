import Foundation

struct HistoricalSourceReference: Identifiable, Equatable, Sendable, Codable {
    let id: String
    let title: String
    let locator: String?
    let url: URL?
    let note: String?

    init(
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
