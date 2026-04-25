import Foundation
import Testing
@testable import AtlasOfTime

struct LocalizationResourceTests {
    @Test(arguments: ["en", "fa"])
    func requiredLocalizationKeysExist(for localeIdentifier: String) throws {
        let table = try LocalizationTestSupport.localizationTable(
            localeIdentifier: localeIdentifier,
            sourceFilePath: #filePath
        )

        for key in LocalizationKeyCatalog.required {
            #expect(table[key] != nil, "Missing localization key '\(key)' for locale '\(localeIdentifier)'")
        }
    }

    @Test
    func englishAppearanceSummaryFormatResolvesCorrectly() throws {
        try #expect(
            LocalizationTestSupport.normalizedForComparison(
                try LocalizationTestSupport.resolvedString(
                    localeIdentifier: "en",
                    key: "settings.appearance.preview.summary",
                    locale: Locale(identifier: "en"),
                    sourceFilePath: #filePath,
                    "Light",
                    "glass surfaces on"
                )
            ) == "Light mode with glass surfaces on."
        )
    }

    @Test
    func persianAppearanceSummaryFormatResolvesCorrectly() throws {
        try #expect(
            LocalizationTestSupport.normalizedForComparison(
                try LocalizationTestSupport.resolvedString(
                    localeIdentifier: "fa",
                    key: "settings.appearance.preview.summary",
                    locale: Locale(identifier: "fa"),
                    sourceFilePath: #filePath,
                    "روشن",
                    "سطوح شیشه‌ای فعال"
                )
            ) == "حالت روشن با سطوح شیشه‌ای فعال."
        )
    }

    @Test
    func englishSelectedYearAccessibilityFormatResolvesCorrectly() throws {
        try #expect(
            LocalizationTestSupport.normalizedForComparison(
                try LocalizationTestSupport.resolvedString(
                    localeIdentifier: "en",
                    key: "accessibility.timeline.selectedYear",
                    locale: Locale(identifier: "en"),
                    sourceFilePath: #filePath,
                    Int64(1900)
                )
            ) == "Selected year 1,900"
        )
    }

    @Test
    func persianSelectedYearAccessibilityFormatResolvesCorrectly() throws {
        try #expect(
            LocalizationTestSupport.normalizedForComparison(
                try LocalizationTestSupport.resolvedString(
                    localeIdentifier: "fa",
                    key: "accessibility.timeline.selectedYear",
                    locale: Locale(identifier: "fa"),
                    sourceFilePath: #filePath,
                    Int64(1900)
                )
            ) == "سال انتخاب‌شده ۱٬۹۰۰"
        )
    }

    @Test
    func typedLocalizationNamespacesReferenceKnownKeys() throws {
        let englishTable = try LocalizationTestSupport.localizationTable(
            localeIdentifier: "en",
            sourceFilePath: #filePath
        )

        let knownKeys = Set(LocalizationKeyCatalog.required)

        for key in LocalizationKeyCatalog.typedReferencedByAppStrings {
            #expect(knownKeys.contains(key))
            #expect(englishTable[key] != nil, "Typed key '\(key)' is not present in English resources")
        }
    }
}
