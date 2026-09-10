//
//  SettingsCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI

nonisolated enum SettingsRoute: Hashable {
    case start
}

@Observable
class SettingsCoordinator: NavigationCoordinator, AlertCoordinator {
    typealias NavigationRoute = SettingsRoute
    
    var presentAlert: AlertConfig?
    var alertQueue: [AlertConfig] = []
    
    var path: NavigationPath = NavigationPath()
    
    @ObservationIgnored
    lazy var settingsViewModel: SettingsViewModel = {
        SettingsViewModel(
            service: TipJarServiceImpl(),
            coordinator: self
        )
    }()
    
    @ViewBuilder
    func build(route: SettingsRoute) -> some View {
        switch route {
        case .start:
            SettingsView(viewModel: settingsViewModel)
        }
    }
}
