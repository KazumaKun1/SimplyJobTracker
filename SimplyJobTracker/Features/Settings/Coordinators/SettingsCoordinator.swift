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
class SettingsCoordinator: NavigationCoordinator {
    typealias NavigationRoute = SettingsRoute
    
    var path: NavigationPath = NavigationPath()
    
    @ViewBuilder
    func build(route: SettingsRoute) -> some View {
        Text("Settings")
    }
}
