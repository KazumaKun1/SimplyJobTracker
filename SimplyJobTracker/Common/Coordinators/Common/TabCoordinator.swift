//
//  TabCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI
import SwiftData

enum AppTab: String {
    case home
    case settings
}

@Observable
final class TabCoordinator {
    var selectedTab: AppTab = .home
    
    let homeCoordinator: HomeCoordinator
    var settingsCoordinator = SettingsCoordinator()
    
    init(modelContainer: ModelContainer) {
        self.homeCoordinator = HomeCoordinator(modelContainer: modelContainer)
    }
    
    func changeTab(to tab: AppTab) {
        selectedTab = tab
    }
}
