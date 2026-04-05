import Foundation

extension AppLanguageOption {
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
