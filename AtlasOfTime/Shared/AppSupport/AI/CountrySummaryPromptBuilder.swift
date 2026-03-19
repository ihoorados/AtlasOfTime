import Foundation

struct CountrySummaryPromptBuilder: Sendable {
    let instructions: String

    init(instructions: String = Self.defaultInstructions) {
        self.instructions = instructions
    }

    func makePrompt(for request: CountrySummaryRequest) -> String {
        var sections: [String] = []

        sections.append(
            """
            Country Summary Request

            Year: \(request.year)
            Country ID: \(request.countryID)
            Entity ID: \(request.entityID)
            Display Name: \(request.displayName)
            Short Name: \(request.shortDisplayName ?? "None")
            Formal Name: \(request.formalName ?? "None")
            Name Confidence: \(request.nameConfidence.rawValue)
            Border Confidence: \(request.borderConfidence.rawValue)
            """
        )

        if request.relationships.isEmpty {
            sections.append("Relationships:\n- None provided")
        } else {
            let relationshipLines = request.relationships.map { relationship in
                "- \(relationship.type.rawValue): \(relationship.targetDisplayName) [confidence: \(relationship.confidence.rawValue)]"
            }
            sections.append("Relationships:\n" + relationshipLines.joined(separator: "\n"))
        }

        if request.sourceReferences.isEmpty {
            sections.append("Sources:\n- No explicit sources provided")
        } else {
            let sourceLines = request.sourceReferences.map { source in
                var line = "- \(source.title)"
                if let locator = source.locator, !locator.isEmpty {
                    line += " (\(locator))"
                }
                if let note = source.note, !note.isEmpty {
                    line += " - \(note)"
                }
                return line
            }
            sections.append("Sources:\n" + sourceLines.joined(separator: "\n"))
        }

        sections.append(
            """
            Output Requirements:
            - Keep the summary historically cautious.
            - Do not invent facts beyond the provided context.
            - Mention uncertainty directly when confidence is low or unknown.
            - Focus on political identity, territorial context, and historical relationships for the selected year.
            - Return concise, user-facing prose suitable for a historical atlas detail screen.
            """
        )

        return sections.joined(separator: "\n\n")
    }
}

extension CountrySummaryPromptBuilder {
    static let defaultInstructions = """
    You are generating a historical atlas country summary for one selected year.
    Use only the supplied context.
    Prefer historically careful wording over confident speculation.
    If the context is incomplete or uncertain, say so plainly.
    Write concise English for a user-facing country detail screen.
    """
}
