import Foundation

enum AppStrings {
    enum Common {
        static let appName: LocalizedStringResource = "common.appName"
        static let unavailableValue: LocalizedStringResource = "common.unavailableValue"
    }

    enum Tabs {
        static let home: LocalizedStringResource = "tabs.home"
        static let settings: LocalizedStringResource = "tabs.settings"
    }

    enum Settings {
        enum Root {
            static let title: LocalizedStringResource = "settings.root.title"
            static let appearance: LocalizedStringResource = "settings.root.appearance"
            static let map: LocalizedStringResource = "settings.root.map"
            static let data: LocalizedStringResource = "settings.root.data"
        }

        enum Appearance {
            static let title: LocalizedStringResource = "settings.appearance.title"
            static let sectionTitle: LocalizedStringResource = "settings.appearance.section.title"
            static let appAppearance: LocalizedStringResource = "settings.appearance.appAppearance"
            static let liquidGlassTitle: LocalizedStringResource = "settings.appearance.liquidGlass.title"
            static let glassSurfaces: LocalizedStringResource = "settings.appearance.liquidGlass.glassSurfaces"
            static let liquidGlassFooter: LocalizedStringResource = "settings.appearance.liquidGlass.footer"
            static let previewTitle: LocalizedStringResource = "settings.appearance.preview.title"
            static let previewCardTitle: LocalizedStringResource = "settings.appearance.preview.cardTitle"
            static let previewLight: LocalizedStringResource = "settings.appearance.preview.light"
            static let previewDark: LocalizedStringResource = "settings.appearance.preview.dark"
            static let previewGlass: LocalizedStringResource = "settings.appearance.preview.glass"
            static let previewGlassEnabled: LocalizedStringResource = "settings.appearance.preview.glassEnabled"
            static let previewGlassReduced: LocalizedStringResource = "settings.appearance.preview.glassReduced"
            static let previewSummaryFormat: String = "settings.appearance.preview.summary"
            static let reset: LocalizedStringResource = "settings.appearance.reset"
        }

        enum Map {
            static let title: LocalizedStringResource = "settings.map.title"
            static let presentationTitle: LocalizedStringResource = "settings.map.presentation.title"
            static let showYearRangeLabels: LocalizedStringResource = "settings.map.showYearRangeLabels"
            static let showLoadingIndicator: LocalizedStringResource = "settings.map.showLoadingIndicator"
            static let presentationFooter: LocalizedStringResource = "settings.map.presentation.footer"
            static let reset: LocalizedStringResource = "settings.map.reset"
        }

        enum Data {
            static let title: LocalizedStringResource = "settings.data.title"
            static let datasetTitle: LocalizedStringResource = "settings.data.dataset.title"
            static let source: LocalizedStringResource = "settings.data.dataset.source"
            static let bundled: LocalizedStringResource = "settings.data.dataset.bundled"
            static let format: LocalizedStringResource = "settings.data.dataset.format"
            static let geoJSONGzip: LocalizedStringResource = "settings.data.dataset.geojsonGzip"
            static let datasetFooter: LocalizedStringResource = "settings.data.dataset.footer"
            static let loadingTitle: LocalizedStringResource = "settings.data.loading.title"
            static let caching: LocalizedStringResource = "settings.data.loading.caching"
            static let automatic: LocalizedStringResource = "settings.data.loading.automatic"
            static let yearIndex: LocalizedStringResource = "settings.data.loading.yearIndex"
            static let cachedInMemory: LocalizedStringResource = "settings.data.loading.cachedInMemory"
            static let loadingFooter: LocalizedStringResource = "settings.data.loading.footer"
        }
    }

    enum AppearanceOptions {
        static let systemTitle: LocalizedStringResource = "appearance.option.system.title"
        static let lightTitle: LocalizedStringResource = "appearance.option.light.title"
        static let darkTitle: LocalizedStringResource = "appearance.option.dark.title"
        static let systemSummary: LocalizedStringResource = "appearance.option.system.summary"
        static let lightSummary: LocalizedStringResource = "appearance.option.light.summary"
        static let darkSummary: LocalizedStringResource = "appearance.option.dark.summary"
    }

    enum Errors {
        static let resourceNotFoundFormat: String = "errors.resourceNotFound"
        static let fileReadFailedFormat: String = "errors.fileReadFailed"
        static let invalidIndexFormatFormat: String = "errors.invalidIndexFormat"
        static let invalidGeoJSONFormat: String = "errors.invalidGeoJSON"
        static let yearUnavailableFormat: String = "errors.yearUnavailable"
        static let yearIndexNotLoaded: LocalizedStringResource = "errors.yearIndexNotLoaded"
        static let decompressionFailedFormat: String = "errors.decompressionFailed"
        static let cancelled: LocalizedStringResource = "errors.cancelled"
        static let unexpectedErrorFormat: String = "errors.unexpectedError"
        static let loadingMapBorders: LocalizedStringResource = "errors.loadingMapBorders"
        static let unexpectedFallback: LocalizedStringResource = "errors.unexpectedFallback"
    }

    enum Accessibility {
        enum Common {
            static let on: LocalizedStringResource = "accessibility.common.on"
            static let off: LocalizedStringResource = "accessibility.common.off"
        }

        enum Timeline {
            static let yearSliderLabel: LocalizedStringResource = "accessibility.timeline.yearSlider.label"
            static let yearSliderHint: LocalizedStringResource = "accessibility.timeline.yearSlider.hint"
            static let selectedYearFormat: String = "accessibility.timeline.selectedYear"
        }

        enum AppearanceSettings {
            static let appAppearanceValueFormat: String = "accessibility.appearance.appAppearance.value"
            static let glassSurfacesValueFormat: String = "accessibility.appearance.glassSurfaces.value"
        }

        enum MapSettings {
            static let yearRangeLabelsValueFormat: String = "accessibility.map.yearRangeLabels.value"
            static let loadingIndicatorValueFormat: String = "accessibility.map.loadingIndicator.value"
        }
    }
}
