//
//  AppCoordinatorView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI

struct AppCoordinatorView: View {
    @Bindable var coordinator: TabCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                HomeView(coordinator: coordinator.homeCoordinator)
            }
            Tab("Settings", systemImage: "gear", value: AppTab.settings) {
                SettingsView(coordinator: coordinator.settingsCoordinator)
            }
        }
    }
}

private extension AppCoordinatorView {
    
    // TODO: - Right now, we stick to concrete types as there's no plan to extend this. Note this for future.
    
    struct HomeView: View {
        @Bindable var coordinator: HomeCoordinator

        var body: some View {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(route: .start)
                    .navigationDestination(for: HomeRoute.self) { route in
                        coordinator.build(route: route)
                    }
            }
            .sheet(item: $coordinator.presentedSheet) { sheet in
                coordinator.build(sheet: sheet)
                    .presentationDragIndicator(.visible)
            }
        }
    }

    struct SettingsView: View {
        @Bindable var coordinator: SettingsCoordinator

        var body: some View {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(route: .start)
                    .navigationDestination(for: SettingsRoute.self) { route in
                        coordinator.build(route: route)
                    }
            }
        }
    }
}
