import Testing
@testable import AtlasOfTime

@MainActor
struct AppDIContainerAssemblyTests {
    @Test
    func appContainerCanAssembleAtlasViewModel() {
        let container = AppDIContainer()
        let viewModel = container.makeAtlasViewModel()

        #expect(viewModel.displayYear == 0)
    }
}

