import SwiftUI

extension AppAppearanceOption {
    var title: String {
        switch self {
        case .system:
            String(localized: AppStrings.AppearanceOptions.systemTitle)
        case .light:
            String(localized: AppStrings.AppearanceOptions.lightTitle)
        case .dark:
            String(localized: AppStrings.AppearanceOptions.darkTitle)
        }
    }

    var systemImage: String {
        switch self {
        case .system:
            "circle.lefthalf.filled"
        case .light:
            "sun.max"
        case .dark:
            "moon"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var summary: String {
        switch self {
        case .system:
            String(localized: AppStrings.AppearanceOptions.systemSummary)
        case .light:
            String(localized: AppStrings.AppearanceOptions.lightSummary)
        case .dark:
            String(localized: AppStrings.AppearanceOptions.darkSummary)
        }
    }
}
