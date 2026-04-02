import Foundation

public struct HistoricalEntity: Identifiable, Equatable, Sendable, Codable {
    public let id: String
    public let canonicalName: String
    public let externalIDs: ExternalIDs

    public init(
        id: String,
        canonicalName: String,
        externalIDs: ExternalIDs = .init()
    ) {
        self.id = id
        self.canonicalName = canonicalName
        self.externalIDs = externalIDs
    }
}

public struct ExternalIDs: Equatable, Sendable, Codable {
    public let wikidata: String?

    public init(wikidata: String? = nil) {
        self.wikidata = wikidata
    }
}
