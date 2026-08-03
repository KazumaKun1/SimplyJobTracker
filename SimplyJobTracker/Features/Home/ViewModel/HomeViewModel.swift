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
        Task {
            do {
                try await service.createJobApplication()
            } catch {
                // TODO: - Handle alert here
            }
        }
    }
}

// MARK: - Navigation
extension HomeViewModel {
    func filterTapped() {
        coordinator?.presentSheet(.filter)
    }
    
    func editApplicationTapped() {
        coordinator?.navigate(to: .editApplication)
    }
}
