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

    private static func projectRootURL(sourceFilePath: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: sourceFilePath))
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
