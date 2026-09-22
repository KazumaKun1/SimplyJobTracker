//
//  HomeCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI
import SwiftData
import FoundationModels

nonisolated enum HomeRoute: Hashable {
    case start
    case applicationDetails(JobApplication)
    case editApplication(JobApplication)
}

enum HomeSheetRoute: Identifiable {
    case filter(Binding<JobApplicationFilter>)
    case search([JobApplication])
    case applicationHealthCheck(JobApplication)

    var id: String {
        switch self {
        case .filter: "filter"
        case .search: "search"
        case .applicationHealthCheck: "applicationHealthCheck"
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

    /* Checked once at app start rather than on every view body recomputation, since `SystemLanguageModel.default.availability` talks to a system model-management service that can be slow or unstable (e.g. while an on-device model update is in progress). Refreshed via `refreshHealthCheckAvailability()` whenever the app becomes active, so the button appears without requiring a relaunch once the model finishes downloading.
     */
    var isHealthCheckAvailable: Bool

    @ObservationIgnored
    private lazy var jobApplicationService: JobApplicationService = JobApplicationServiceImpl(modelContainer: modelContainer)

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
        isHealthCheckAvailable = Self.checkHealthCheckAvailability()
    }

    func refreshHealthCheckAvailability() {
        isHealthCheckAvailable = Self.checkHealthCheckAvailability()
    }

    private static func checkHealthCheckAvailability() -> Bool {
        if #available(iOS 26.0, *) {
            SystemLanguageModel.default.availability == .available
        } else {
            false
        }
    }
    
    @ViewBuilder
    func build(route: HomeRoute) -> some View {
        switch route {
        case .start:
            HomeView(viewModel: homeViewModel)
        case .applicationDetails(let application):
            ApplicationDetailsView(jobApplication: application, viewModel: editJobApplicationViewModel, coordinator: self)
        case .editApplication(let application):
            EditJobApplicationView(jobApplication: application, viewModel: editJobApplicationViewModel)
        }
    }
    
    @ViewBuilder
    func build(sheet: HomeSheetRoute) -> some View {
        switch sheet {
        case .filter(let filter):
            FilterView(filter: filter)
        case .search(let applications):
            SearchView(applications: applications, onSelect: homeViewModel.editApplicationTapped)
        case .applicationHealthCheck(let application):
            if #available(iOS 26.0, *) {
                ApplicationHealthCheckView(
                    viewModel: ApplicationHealthCheckViewModel(
                        service: ApplicationHealthCheckServiceImpl(),
                        jobApplication: application
                    )
                )
            } else {
                EmptyView()
            }
        }
    }
}

extension HomeCoordinator {
    func presentSheet(_ route: HomeSheetRoute) { presentedSheet = route }
    func dismissSheet() { presentedSheet = nil }
}
