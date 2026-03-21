import Foundation

public struct AtlasMapCameraState: Equatable, Sendable {
    public let center: AtlasMapCoordinate
    public let latitudeDelta: Double
    public let longitudeDelta: Double

    public init(
        center: AtlasMapCoordinate,
        latitudeDelta: Double,
        longitudeDelta: Double
    ) {
        self.center = center
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }

    public static let world = AtlasMapCameraState(
        center: AtlasMapCoordinate(latitude: 20, longitude: 0),
        latitudeDelta: 150,
        longitudeDelta: 360
    )
}
