//
//  HomeViewModel.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/2/26.
//

import SwiftUI

@Observable
class HomeViewModel {
    weak private var coordinator: HomeCoordinator?
    
    private let service: JobApplicationService
    
    init(service: JobApplicationService, coordinator: HomeCoordinator) {
        self.service = service
        self.coordinator = coordinator
    }
}

// MARK: - Service
extension HomeViewModel {
    func createApplication() {
        do {
            try service.createJobApplication()
        } catch {
            let generalError = JobTrackerError.generalError
            coordinator?
                .presentAlert(
                    .init(
                        title: generalError.errorDescription ?? "",
                        message: generalError.recoverySuggestion,
                        primaryButton: .init(title: "Ok!")
                    )
                )
        }
    }
}

// MARK: - Navigation
extension HomeViewModel {
    func filterTapped(filter: Binding<JobApplicationFilter>) {
        coordinator?.presentSheet(.filter(filter))
    }
    
    func editApplicationTapped(jobApplication: JobApplication) {
        coordinator?.dismissSheet()
        coordinator?.navigate(to: .applicationDetails(jobApplication))
    }
    
    func searchApplicationTapped(jobApplications: [JobApplication]) {
        coordinator?.presentSheet(.search(jobApplications))
    }
}
