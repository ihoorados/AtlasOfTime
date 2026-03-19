import Combine
import CoreAtlasNavigation
import Foundation

@MainActor
final class AppNavigationStore: ObservableObject {
    @Published var selectedTab: AppTab
    @Published var homeNavigation: NavigationPathState<HomeRoute>
    @Published var settingsNavigation: NavigationPathState<SettingsRoute>

    init(
        selectedTab: AppTab = .home,
        homePath: [HomeRoute] = [],
        settingsPath: [SettingsRoute] = []
    ) {
        self.selectedTab = selectedTab
        self.homeNavigation = NavigationPathState(path: homePath)
        self.settingsNavigation = NavigationPathState(path: settingsPath)
    }

    func push(_ route: HomeRoute) {
        selectedTab = .home
        homeNavigation.push(route)
    }

    func push(_ route: SettingsRoute) {
        selectedTab = .settings
        settingsNavigation.push(route)
    }

    func popHome() {
        homeNavigation.pop()
    }

    func popSettings() {
        settingsNavigation.pop()
    }

    func popToHomeRoot() {
        homeNavigation.popToRoot()
    }

    func popToSettingsRoot() {
        settingsNavigation.popToRoot()
    }

    func reset() {
        selectedTab = .home
        homeNavigation.popToRoot()
        settingsNavigation.popToRoot()
    }
}
