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
            return "Resource not found: \(path)"
        case .fileReadFailed(let path):
            return "Unable to read file: \(path)"
        case .invalidIndexFormat(let details):
            return "Invalid index.json format: \(details)"
        case .invalidGeoJSON(let details):
            return "Invalid GeoJSON: \(details)"
        case .yearUnavailable(let year):
            return "No border data available for year \(year)."
        case .yearIndexNotLoaded:
            return "Year index is not loaded."
        case .decompressionFailed(let reason):
            return "Gzip decompression failed: \(reason)"
        case .cancelled:
            return "Operation cancelled."
        case .unknown(let message):
            return "Unexpected error: \(message)"
        }
    }

    var userMessage: String {
        switch self {
        case .cancelled:
            return ""
        case .unknown:
            return "Something went wrong while loading map borders."
        default:
            return errorDescription ?? "An unexpected error occurred."
        }
    }
}
