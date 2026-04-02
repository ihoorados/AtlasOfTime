import Testing
@testable import CoreAtlasDomain

struct CoreAtlasDomainTests {
    @Test
    func packageLoads() {
        _ = CoreAtlasDomainModule.self
    }
}
