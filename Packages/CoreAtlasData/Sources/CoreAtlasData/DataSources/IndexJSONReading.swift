import Foundation

public protocol IndexJSONReading: Sendable {
    func readIndexJSON() throws -> Data
}
