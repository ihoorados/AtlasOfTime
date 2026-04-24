import Foundation

public enum AtlasDataError: Error, Sendable {
    case resourceNotFound(String)
    case fileReadFailed(String)
    case invalidIndexFormat(String)
    case invalidGeoJSON(String)
    case decompressionFailed(reason: String)
}
