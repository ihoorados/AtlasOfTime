import Testing
@testable import CoreAtlasData

struct CoreAtlasDataTests {
    @Test func packageLoads() {
        #expect(CoreAtlasDataModule.self == CoreAtlasDataModule.self)
    }
}
