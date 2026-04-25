import Foundation
import CoreAtlasData
import CoreAtlasDomain

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
        if let dataError = error as? CoreAtlasData.AtlasDataError {
            switch dataError {
            case .resourceNotFound(let path):
                return .resourceNotFound(path)
            case .fileReadFailed(let path):
                return .fileReadFailed(path)
            case .invalidIndexFormat(let details):
                return .invalidIndexFormat(details)
            case .invalidGeoJSON(let details):
                return .invalidGeoJSON(details)
            case .decompressionFailed(let reason):
                return .decompressionFailed(reason: reason)
            }
        }
        if let domainError = error as? AtlasDomainError {
            switch domainError {
            case .yearUnavailable(let year):
                return .yearUnavailable(year)
            }
        }
        if error is CancellationError {
            return .cancelled
        }
        return .unknown(error.localizedDescription)
    }

    var errorDescription: String? {
        switch self {
        case .resourceNotFound(let path):
            return LocalizedStringFormat.resolve(AppStrings.Errors.resourceNotFoundFormat, locale: .current, path)
        case .fileReadFailed(let path):
            return LocalizedStringFormat.resolve(AppStrings.Errors.fileReadFailedFormat, locale: .current, path)
        case .invalidIndexFormat(let details):
            return LocalizedStringFormat.resolve(AppStrings.Errors.invalidIndexFormatFormat, locale: .current, details)
        case .invalidGeoJSON(let details):
            return LocalizedStringFormat.resolve(AppStrings.Errors.invalidGeoJSONFormat, locale: .current, details)
        case .yearUnavailable(let year):
            return LocalizedStringFormat.resolve(AppStrings.Errors.yearUnavailableFormat, locale: .current, year)
        case .yearIndexNotLoaded:
            return String(localized: AppStrings.Errors.yearIndexNotLoaded)
        case .decompressionFailed(let reason):
            return LocalizedStringFormat.resolve(AppStrings.Errors.decompressionFailedFormat, locale: .current, reason)
        case .cancelled:
            return String(localized: AppStrings.Errors.cancelled)
        case .unknown(let message):
            return LocalizedStringFormat.resolve(AppStrings.Errors.unexpectedErrorFormat, locale: .current, message)
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
}
