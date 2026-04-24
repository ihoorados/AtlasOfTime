import Testing
@testable import CoreAtlasAppSettings

@Test func packageLoads() {
    _ = AppPreferences.default
}
