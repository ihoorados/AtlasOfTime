import Foundation
import CoreAtlasDomain

struct CountrySummaryPromptBuilder: Sendable {
    let instructions: String

    init(instructions: String = Self.defaultInstructions) {
        self.instructions = instructions
    }

    func makePrompt(for request: CountrySummaryRequest) -> String {
        var sections: [String] = []

        sections.append(
            """
            AtlasOfTime Historical Snapshot Request

            Selected Year: \(request.year)
            """
        )

        sections.append(
            """
            Identity
            Display Name: \(sanitizePromptValue(request.displayName) ?? "Not available in current dataset")
            Short Name: \(sanitizePromptValue(request.shortDisplayName) ?? "Not available in current dataset")
            Formal Name: \(sanitizePromptValue(request.formalName) ?? "Not available in current dataset")
            Name Confidence: \(request.nameConfidence.rawValue)
            """
        )

        sections.append(
            """
            Territorial Profile
            Border Confidence: \(request.borderConfidence.rawValue)
            Extent Count: \(request.extentCount)
            Extent Types: \(joinedRawValues(request.extentTypes))
            Border Models: \(joinedRawValues(request.borderModels))
            Multiple Extents Present: \(request.hasMultipleExtents ? "yes" : "no")
            """
        )

        if request.relationships.isEmpty {
            sections.append(
                """
                Political Relationships
                Relationship Count: \(request.relationshipCount)
                - No recorded relationships in current dataset
                """
            )
        } else {
            let relationshipLines = request.relationships.compactMap { relationship -> String? in
                guard let targetName = sanitizePromptValue(relationship.targetDisplayName) else { return nil }
                return "- \(relationship.type.rawValue) -> \(targetName) [confidence: \(relationship.confidence.rawValue)]"
            }

            if relationshipLines.isEmpty {
                sections.append(
                    """
                    Political Relationships
                    Relationship Count: \(request.relationshipCount)
                    - No usable relationship text provided
                    """
                )
            } else {
                sections.append(
                    """
                    Political Relationships
                    Relationship Count: \(request.relationshipCount)
                    \(relationshipLines.joined(separator: "\n"))
                    """
                )
            }
        }

        if request.sourceReferences.isEmpty {
            sections.append(
                """
                Source Basis
                Source Count: \(request.sourceCount)
                - Not available in current dataset
                """
            )
        } else {
            let sourceLines = request.sourceReferences.compactMap(makeSourceLine)
            if sourceLines.isEmpty {
                sections.append(
                    """
                    Source Basis
                    Source Count: \(request.sourceCount)
                    - No usable source text provided
                    """
                )
            } else {
                sections.append(
                    """
                    Source Basis
                    Source Count: \(request.sourceCount)
                    \(sourceLines.joined(separator: "\n"))
                    """
                )
            }
        }

        sections.append(
            """
            Data Confidence
            Name Confidence: \(request.nameConfidence.rawValue)
            Border Confidence: \(request.borderConfidence.rawValue)
            Source Count: \(request.sourceCount)
            Relationship Count: \(request.relationshipCount)

            Task
            Generate a historically careful summary for this snapshot using only the supplied dataset fields.

            Writing Priorities
            1. Identify the polity in the selected year using only the supplied identity fields.
            2. Describe territorial context using extent count, extent types, border models, and border confidence.
            3. Mention political relationships only when they materially clarify the record.
            4. Surface source availability and uncertainty clearly.

            Hard Constraints
            - Use only the supplied context.
            - Do not use external knowledge.
            - Do not invent rulers, capitals, governments, wars, events, populations, religions, chronology, or neighboring states.
            - Do not modernize or normalize historical status beyond the provided evidence.
            - If confidence is medium, low, unknown, disputed, or mixed, explicitly use restrained wording.
            - If the context is sparse, say so plainly rather than filling gaps.
            - Separate observed dataset facts from cautious interpretation.

            Output Rules
            - Title: 2 to 8 words.
            - Overview: 70 to 130 words, summarizing identity, record scope, and uncertainty using only supplied fields.
            - Territorial Context: 1 short paragraph only if territorial evidence adds meaningful detail beyond the overview.
            - Political Context: 1 short paragraph only if relationships materially clarify status or context.
            - Key Facts: 3 to 5 short factual items based only on extent, relationship, source, and confidence data.
            - Confidence Note: 1 short sentence when uncertainty, sparse sources, or mixed evidence materially affects interpretation.
            """
        )

        return sections.joined(separator: "\n\n")
    }

    private func makeSourceLine(from source: CountrySummaryRequest.SourceContext) -> String? {
        guard let title = sanitizePromptValue(source.title) else { return nil }

        var line = "- \(title)"

        if let note = sanitizePromptValue(source.note) {
            line += " - \(note)"
        }

        return line
    }

    private func joinedRawValues<T: RawRepresentable>(_ values: [T]) -> String where T.RawValue == String {
        let rawValues = values.map(\.rawValue)
        return rawValues.isEmpty ? "None" : rawValues.joined(separator: ", ")
    }

    private func sanitizePromptValue(_ value: String?) -> String? {
        guard let value else { return nil }

        let collapsed = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)

        guard !collapsed.isEmpty else { return nil }
        guard !looksLikeMachineIdentifier(collapsed) else { return nil }

        return collapsed
    }

    private func looksLikeMachineIdentifier(_ value: String) -> Bool {
        if value.contains("://") || value.contains("/") || value.contains("\\") {
            return true
        }

        let punctuationCount = value.filter { "|:_#@[]{}<>".contains($0) }.count
        if punctuationCount >= 2 {
            return true
        }

        let letters = value.filter(\.isLetter).count
        let digits = value.filter(\.isNumber).count
        let separators = value.filter { !$0.isLetter && !$0.isNumber && !$0.isWhitespace }.count

        return letters > 0 && digits == 0 && separators > letters / 2
    }
}

extension CountrySummaryPromptBuilder {
    static let defaultInstructions = """
    You are AtlasOfTime Historical Intelligence Engine.

    Generate an accurate, neutral, educational summary for one historical country snapshot at a specific year.
    Use only the supplied structured context.
    Do not use external knowledge.
    Do not add facts that are not directly supported by the request.
    Do not infer rulers, capitals, governments, wars, religions, populations, events, or chronology unless they are explicitly present in the input.
    If data is missing, say so plainly and briefly.
    If confidence is medium, low, unknown, disputed, or mixed, state that uncertainty clearly.
    Prefer precision and restraint over literary language.

    Your job is to produce:
    1. a short title,
    2. a historically careful overview,
    3. optional territorial and political context sections when justified by the input,
    4. concise factual key points,
    5. a confidence note when uncertainty materially affects interpretation.

    Prioritize:
    - the polity's identity in the selected year,
    - territorial evidence from extents and border models,
    - political relationships from the supplied relationship records,
    - source availability and uncertainty,
    - clear separation between observed facts and cautious interpretation.

    If confidence is not high, explicitly avoid definitive wording.
    Write concise English suitable for a production historical atlas UI.
    """
}
