import Foundation

public struct GenerateCountrySummary: Sendable {
    private let generator: any CountrySummaryGenerating

    public init(generator: any CountrySummaryGenerating) {
        self.generator = generator
    }

    public func execute(for snapshot: HistoricalCountrySnapshot) async throws -> CountrySummaryResult {
        let request = makeRequest(for: snapshot)
        return try await generator.generateSummary(for: request)
    }

    public func makeRequest(for snapshot: HistoricalCountrySnapshot) -> CountrySummaryRequest {
        let mergedSources = mergedSourceContexts(for: snapshot)

        return CountrySummaryRequest(
            year: snapshot.year,
            countryID: snapshot.id,
            entityID: snapshot.entityID,
            displayName: snapshot.displayName,
            shortDisplayName: snapshot.shortDisplayName,
            formalName: snapshot.formalName,
            nameConfidence: snapshot.nameConfidence,
            borderConfidence: primaryBorderConfidence(for: snapshot),
            extentCount: snapshot.extents.count,
            extentTypes: Array(Set(snapshot.extents.map(\.extentType))).sorted { $0.rawValue < $1.rawValue },
            borderModels: Array(Set(snapshot.extents.map(\.borderModel))).sorted { $0.rawValue < $1.rawValue },
            hasMultipleExtents: snapshot.extents.count > 1,
            relationshipCount: snapshot.relationships.count,
            sourceCount: mergedSources.count,
            relationships: snapshot.relationships.map(makeRelationshipContext),
            sourceReferences: mergedSources
        )
    }

    private func primaryBorderConfidence(for snapshot: HistoricalCountrySnapshot) -> HistoricalConfidence {
        snapshot.extents.first?.borderConfidence ?? .unknown
    }

    private func makeRelationshipContext(
        from relationship: HistoricalRelationship
    ) -> CountrySummaryRequest.RelationshipContext {
        CountrySummaryRequest.RelationshipContext(
            type: relationship.type,
            targetDisplayName: relationship.targetDisplayName,
            confidence: relationship.confidence
        )
    }

    private func mergedSourceContexts(
        for snapshot: HistoricalCountrySnapshot
    ) -> [CountrySummaryRequest.SourceContext] {
        let allReferences = snapshot.sourceReferences + snapshot.extents.flatMap(\.sourceReferences)
        var seenIDs: Set<String> = []

        return allReferences.compactMap { reference in
            guard seenIDs.insert(reference.id).inserted else { return nil }
            return CountrySummaryRequest.SourceContext(
                title: reference.title,
                locator: reference.locator,
                note: reference.note
            )
        }
    }
}
