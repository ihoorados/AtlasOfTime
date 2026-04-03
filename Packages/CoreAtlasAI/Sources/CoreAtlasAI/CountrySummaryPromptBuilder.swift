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
            Historical Atlas Detail Request

            Selected Year: \(request.year)
            """
        )

        sections.append(
            """
            Identity
            Display Name: \(sanitizePromptValue(request.displayName) ?? "Unknown")
            Short Name: \(sanitizePromptValue(request.shortDisplayName) ?? "None")
            Formal Name: \(sanitizePromptValue(request.formalName) ?? "None")
            Name Confidence: \(request.nameConfidence.rawValue)
            """
        )

        sections.append(
            """
            Territorial Context
            Border Confidence: \(request.borderConfidence.rawValue)
            Extent Count: \(request.extentCount)
            Extent Types: \(joinedRawValues(request.extentTypes))
            Border Models: \(joinedRawValues(request.borderModels))
            Multiple Extents Present: \(request.hasMultipleExtents ? "yes" : "no")
            """
        )

        if request.relationships.isEmpty {
            sections.append("Political Relationships\n- None provided")
        } else {
            let relationshipLines = request.relationships.compactMap { relationship -> String? in
                guard let targetName = sanitizePromptValue(relationship.targetDisplayName) else { return nil }
                return "- \(relationship.type.rawValue): \(targetName) [confidence: \(relationship.confidence.rawValue)]"
            }

            if relationshipLines.isEmpty {
                sections.append("Political Relationships\n- No usable relationship text provided")
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
            sections.append("Sources\n- No explicit sources provided")
        } else {
            let sourceLines = request.sourceReferences.compactMap(makeSourceLine)
            if sourceLines.isEmpty {
                sections.append("Sources\n- No usable source text provided")
            } else {
                sections.append(
                    """
                    Sources
                    Source Count: \(request.sourceCount)
                    \(sourceLines.joined(separator: "\n"))
                    """
                )
            }
        }

        sections.append(
            """
            Task
            Generate a historically careful atlas detail summary for this polity in the selected year.

            Writing Priorities
            1. Identify what this polity is in the selected year.
            2. Describe territorial or border context using only the supplied evidence.
            3. Mention political relationships only when they materially clarify status.
            4. State uncertainty clearly when names, borders, or relationships are weakly supported.

            Hard Constraints
            - Use only the supplied context.
            - Do not invent rulers, capitals, wars, populations, religions, chronology, or neighboring states.
            - Do not modernize or normalize historical status beyond the provided evidence.
            - If confidence is low or unknown, use restrained wording such as "the available data suggests" or "the source context is limited".
            - If the context is sparse, say so plainly rather than filling gaps.

            Output Rules
            - Title: 2 to 8 words.
            - Overview: 70 to 130 words, suitable for a production historical atlas screen.
            - Territorial Context: 1 short paragraph only if there is meaningful territorial or border context to add beyond the overview.
            - Political Context: 1 short paragraph only if relationships materially clarify status.
            - Key Facts: 3 to 5 short factual items, each under 16 words.
            - Confidence Note: 1 short sentence only if uncertainty materially affects interpretation.
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
    You are generating a historical atlas detail summary for one polity in one selected year.

    Use only the supplied structured context.
    Do not add facts that are not directly supported by the request.
    Do not infer rulers, capitals, wars, religions, populations, or events unless they are explicitly present in the input.
    When the context is incomplete, say so plainly and briefly.
    Prefer precision and restraint over literary language.

    Your job is to produce:
    1. a short title,
    2. a historically careful overview,
    3. optional territorial and political context sections when justified by the input,
    4. concise key facts,
    5. a confidence note when uncertainty materially affects interpretation.

    Prioritize:
    - the polity's identity in the selected year,
    - its territorial or border context,
    - its political relationships,
    - uncertainty and source limitations.

    If confidence is low or unknown, explicitly avoid definitive wording.
    Write concise English suitable for a production historical atlas UI.
    """
}
