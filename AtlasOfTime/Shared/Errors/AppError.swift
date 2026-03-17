import Foundation

enum AppError: Error, LocalizedError, Sendable {
    case resourceNotFound(String)
    case fileReadFailed(String)
    case invalidIndexFormat(String)
    case invalidGeoJSON(String)
    case yearUnavailable(Int)
    case yearIndexNotLoaded
    case decompressionFailed(reason: String)
    case cancelled
    case unknown(String)

    static func wrap(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        if error is CancellationError {
            return .cancelled
        }
        return .unknown(error.localizedDescription)
    }

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            return localizedString(AppStrings.Errors.resourceNotFoundFormat, path)
        case .fileReadFailed(let path):
            return localizedString(AppStrings.Errors.fileReadFailedFormat, path)
        case .invalidIndexFormat(let details):
            return localizedString(AppStrings.Errors.invalidIndexFormatFormat, details)
        case .invalidGeoJSON(let details):
            return localizedString(AppStrings.Errors.invalidGeoJSONFormat, details)
        case .yearUnavailable(let year):
            return localizedString(AppStrings.Errors.yearUnavailableFormat, year)
        case .yearIndexNotLoaded:
            return String(localized: AppStrings.Errors.yearIndexNotLoaded)
        case .decompressionFailed(let reason):
            return localizedString(AppStrings.Errors.decompressionFailedFormat, reason)
        case .cancelled:
            return String(localized: AppStrings.Errors.cancelled)
        case .unknown(let message):
            return localizedString(AppStrings.Errors.unexpectedErrorFormat, message)
        }
    }

    var userMessage: String {
        switch self {
        case .cancelled:
            return ""
        case .unknown:
            return String(localized: AppStrings.Errors.loadingMapBorders)
        default:
            return errorDescription ?? String(localized: AppStrings.Errors.unexpectedFallback)
        }
    }

    private func localizedString(_ key: String, _ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}
