import Foundation

struct HistoricalEntity: Identifiable, Equatable, Sendable, Codable {
    let id: String
    let canonicalName: String
    let externalIDs: ExternalIDs

    init(
        id: String,
        canonicalName: String,
        externalIDs: ExternalIDs = .init()
    ) {
        self.id = id
        self.canonicalName = canonicalName
        self.externalIDs = externalIDs
    }
}

struct ExternalIDs: Equatable, Sendable, Codable {
    let wikidata: String?

    init(wikidata: String? = nil) {
        self.wikidata = wikidata
    }
}
