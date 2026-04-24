import Foundation
import Testing

enum LocalizationTestSupport {
    static func localizationTable(
        localeIdentifier: String,
        sourceFilePath: StaticString = #filePath
    ) throws -> [String: String] {
        let stringsURL = projectRootURL(sourceFilePath: sourceFilePath)
            .appending(path: "AtlasOfTime")
            .appending(path: "\(localeIdentifier).lproj")
            .appending(path: "Localizable.strings")

        return try #require(
            NSDictionary(contentsOf: stringsURL) as? [String: String],
            "Unable to load localization table at \(stringsURL.path(percentEncoded: false))"
        )
    }

    static func resolvedString(
        localeIdentifier: String,
        key: String,
        locale: Locale,
        sourceFilePath: StaticString = #filePath,
        _ arguments: CVarArg...
    ) throws -> String {
        let table = try localizationTable(localeIdentifier: localeIdentifier, sourceFilePath: sourceFilePath)
        let format = try #require(table[key], "Missing format key '\(key)' for locale '\(localeIdentifier)'")
        return String(format: format, locale: locale, arguments: arguments)
    }

    static func normalizedForComparison(_ value: String) -> String {
        let bidiFormattingScalars = CharacterSet(charactersIn: "\u{200E}\u{200F}\u{061C}\u{2066}\u{2067}\u{2068}\u{2069}")
        return String(value.unicodeScalars.filter { !bidiFormattingScalars.contains($0) })
    }

    private static func projectRootURL(sourceFilePath: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: sourceFilePath))
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
