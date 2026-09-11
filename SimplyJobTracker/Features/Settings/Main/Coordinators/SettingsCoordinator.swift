//
//  SettingsCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI
import SwiftData

nonisolated enum SettingsRoute: Hashable {
    case start
}

@Observable
class SettingsCoordinator: NavigationCoordinator, AlertCoordinator {
    typealias NavigationRoute = SettingsRoute
    
    var presentAlert: AlertConfig?
    var alertQueue: [AlertConfig] = []
    
    var path: NavigationPath = NavigationPath()
    
    private let modelContainer: ModelContainer
    
    @ObservationIgnored
    private lazy var jobApplicationService: JobApplicationService = JobApplicationServiceImpl(modelContainer: modelContainer)
    
    @ObservationIgnored
    lazy var settingsViewModel: SettingsViewModel = {
        SettingsViewModel(
            jobApplicationService: jobApplicationService,
            tipService: TipJarServiceImpl(),
            coordinator: self
        )
    }()
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @ViewBuilder
    func build(route: SettingsRoute) -> some View {
        switch route {
        case .start:
            SettingsView(viewModel: settingsViewModel)
        }
    }
}
