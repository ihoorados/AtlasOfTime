import Testing
@testable import AtlasOfTime

@MainActor
struct DILifetimeTests {
    @Test
    func dataContainerKeepsRepositoriesAppScoped() {
        let container = DataDIContainer()

        let yearIndexRepositoryA = container.makeYearIndexRepository()
        let yearIndexRepositoryB = container.makeYearIndexRepository()
        #expect(
            ObjectIdentifier(yearIndexRepositoryA as AnyObject) ==
            ObjectIdentifier(yearIndexRepositoryB as AnyObject)
        )

        let borderRepositoryA = container.makeBorderRepository()
        let borderRepositoryB = container.makeBorderRepository()
        #expect(
            ObjectIdentifier(borderRepositoryA as AnyObject) ==
            ObjectIdentifier(borderRepositoryB as AnyObject)
        )
    }

    @Test
    func appContainerCreatesNewViewModelInstances() {
        let container = AppDIContainer()

        let first = container.makeAtlasViewModel()
        let second = container.makeAtlasViewModel()

        #expect(first !== second)
    }
}
