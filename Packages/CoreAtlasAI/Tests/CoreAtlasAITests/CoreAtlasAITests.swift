import Testing
import CoreAtlasDomain
@testable import CoreAtlasAI

@Test
func packageLoads() {
    _ = CoreAtlasAI.self
}

@Test
func promptIncludesSchemaAlignedSectionsAndValues() {
    let request = CountrySummaryRequest(
        year: 1683,
        countryID: "country:ottoman",
        entityID: "entity:ottoman",
        displayName: "Ottoman Empire",
        shortDisplayName: "Ottomans",
        formalName: "Ottoman Empire",
        nameConfidence: .medium,
        borderConfidence: .medium,
        extentCount: 2,
        extentTypes: [.control, .claim],
        borderModels: [.lineWithUncertainty, .approximateLine],
        hasMultipleExtents: true,
        relationshipCount: 1,
        sourceCount: 2,
        relationships: [
            .init(
                type: .subjectOf,
                targetDisplayName: "Crimean Khanate",
                confidence: .medium
            )
        ],
        sourceReferences: [
            .init(title: "Preview Historical Dataset", locator: "folio 12", note: "compiled record"),
            .init(title: "Imperial Border Ledger")
        ]
    )

    let prompt = CountrySummaryPromptBuilder().makePrompt(for: request)

    #expect(prompt.contains("AtlasOfTime Historical Snapshot Request"))
    #expect(prompt.contains("Identity"))
    #expect(prompt.contains("Territorial Profile"))
    #expect(prompt.contains("Political Relationships"))
    #expect(prompt.contains("Source Basis"))
    #expect(prompt.contains("Data Confidence"))
    #expect(prompt.contains("Display Name: Ottoman Empire"))
    #expect(prompt.contains("Extent Count: 2"))
    #expect(prompt.contains("Multiple Extents Present: yes"))
    #expect(prompt.contains("- subjectOf -> Crimean Khanate [confidence: medium]"))
    #expect(prompt.contains("Source Count: 2"))
}

@Test
func promptIncludesStrictGuardrailsAgainstUnsupportedFacts() {
    let prompt = CountrySummaryPromptBuilder.defaultInstructions

    #expect(prompt.contains("Do not use external knowledge."))
    #expect(prompt.contains("Do not infer rulers, capitals, governments, wars, religions, populations, events, or chronology"))
    #expect(prompt.contains("If confidence is medium, low, unknown, disputed, or mixed, state that uncertainty clearly."))
    #expect(prompt.contains("clear separation between observed facts and cautious interpretation"))
}

@Test
func promptUsesDatasetFallbacksForSparseRequests() {
    let request = CountrySummaryRequest(
        year: 500,
        countryID: "country:test",
        entityID: "entity:test",
        displayName: "Test Polity"
    )

    let prompt = CountrySummaryPromptBuilder().makePrompt(for: request)

    #expect(prompt.contains("Short Name: Not available in current dataset"))
    #expect(prompt.contains("Formal Name: Not available in current dataset"))
    #expect(prompt.contains("Relationship Count: 0"))
    #expect(prompt.contains("- No recorded relationships in current dataset"))
    #expect(prompt.contains("Source Count: 0"))
    #expect(prompt.contains("- Not available in current dataset"))
}
