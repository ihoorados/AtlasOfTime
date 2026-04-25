import Testing
@testable import CoreAtlasNavigation

@Test
func navigationPathStatePushAndPop() {
    var state = NavigationPathState<String>()

    state.push("detail")
    #expect(state.path == ["detail"])

    state.pop()
    #expect(state.path.isEmpty)
}
