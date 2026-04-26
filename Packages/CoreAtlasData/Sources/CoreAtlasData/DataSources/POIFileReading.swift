import Foundation

public protocol POIFileReading: Sendable {
    func readPOIFile(relativePath: String) throws -> Data
}
