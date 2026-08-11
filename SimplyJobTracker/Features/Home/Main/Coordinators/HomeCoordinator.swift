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
    case editApplication(JobApplication)
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
    var alertQueue: [AlertConfig] = []
    
    typealias NavigationRoute = HomeRoute
    
    var path: NavigationPath = NavigationPath()
    var presentedSheet: HomeSheetRoute?
    
    private let modelContainer: ModelContainer

    @ObservationIgnored
    private lazy var jobApplicationService: JobApplicationService = JobApplicationServiceImpl(modelContext: modelContainer.mainContext)

    @ObservationIgnored
    private lazy var interviewService: InterviewService = InterviewServiceImpl(modelContext: modelContainer.mainContext)

    @ObservationIgnored
    lazy var homeViewModel: HomeViewModel = {
        HomeViewModel(
            service: jobApplicationService,
            coordinator: self
        )
    }()

    @ObservationIgnored
    lazy var editJobApplicationViewModel: EditJobApplicationViewModel = {
        EditJobApplicationViewModel(
            jobApplicationService: jobApplicationService,
            interviewService: interviewService,
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
        case .editApplication(let application):
            EditJobApplicationView(jobApplication: application, viewModel: editJobApplicationViewModel)
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
