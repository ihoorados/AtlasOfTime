import Foundation

protocol IndexJSONReading: Sendable {
    func readIndexJSON() throws -> Data
}
