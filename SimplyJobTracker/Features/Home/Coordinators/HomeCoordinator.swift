//
//  HomeCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI
import SwiftData

nonisolated enum HomeRoute: Hashable {
    case start
    case editApplication
}

enum HomeSheetRoute: Identifiable {
    case filter

    var id: String {
        switch self {
        case .filter: "filter"
        }
    }
}

@Observable
class HomeCoordinator: NavigationCoordinator, AlertCoordinator {
    var presentAlert: AlertConfig?
    
    typealias NavigationRoute = HomeRoute
    
    var path: NavigationPath = NavigationPath()
    var presentedSheet: HomeSheetRoute?
    
    private let modelContainer: ModelContainer
    
    @ObservationIgnored
    lazy var homeViewModel: HomeViewModel = {
        HomeViewModel(
            service: JobApplicationServiceImpl(modelContainer: modelContainer),
            coordinator: self
        )
    }()
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @ViewBuilder
    func build(route: HomeRoute) -> some View {
        switch route {
        case .start:
            HomeView(viewModel: homeViewModel)
        case .editApplication:
            Text("Edit")
        }
    }
    
    @ViewBuilder
    func build(sheet: HomeSheetRoute) -> some View {
        switch sheet {
        case .filter:
            Text("")
        }
    }
}

extension HomeCoordinator {
    func presentSheet(_ route: HomeSheetRoute) { presentedSheet = route }
    func dismissSheet() { presentedSheet = nil }
}
