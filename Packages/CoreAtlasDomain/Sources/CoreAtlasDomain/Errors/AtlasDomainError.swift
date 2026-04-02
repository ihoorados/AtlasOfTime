import Foundation

public enum AtlasDomainError: Error, Sendable {
    case yearUnavailable(Int)
}
