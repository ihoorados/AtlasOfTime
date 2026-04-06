import CoreAtlasAppSettings
import Foundation

extension CoreAtlasAppSettings.AppLanguageOption {
    var title: LocalizedStringResource {
        switch self {
        case .system:
            AppStrings.LanguageOptions.systemTitle
        case .english:
            AppStrings.LanguageOptions.englishTitle
        case .persian:
            AppStrings.LanguageOptions.persianTitle
        }
    }
}
