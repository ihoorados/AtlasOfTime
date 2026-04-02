import Foundation

public struct AtlasMapViewState: Sendable {
    public let snapshot: AtlasMapSnapshot?
    public let camera: AtlasMapCameraState
    public let selection: AtlasMapSelectionState
    public let options: AtlasMapViewOptions

    public init(
        snapshot: AtlasMapSnapshot?,
        camera: AtlasMapCameraState = .world,
        selection: AtlasMapSelectionState = .init(),
        options: AtlasMapViewOptions = .init()
    ) {
        self.snapshot = snapshot
        self.camera = camera
        self.selection = selection
        self.options = options
    }
}
