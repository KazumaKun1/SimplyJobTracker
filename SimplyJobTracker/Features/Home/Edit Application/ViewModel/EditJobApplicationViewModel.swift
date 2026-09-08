//
//  EditJobApplicationViewModel.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/11/26.
//

import SwiftUI
import SwiftData

@Observable
class EditJobApplicationViewModel {
    weak private var coordinator: HomeCoordinator?

    private let jobApplicationService: JobApplicationService
    private let interviewService: InterviewService

    init(jobApplicationService: JobApplicationService, interviewService: InterviewService, coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        self.jobApplicationService = jobApplicationService
        self.interviewService = interviewService
    }
}

// MARK: - Services
extension EditJobApplicationViewModel {
    func addInterview(to jobApplication: JobApplication) {
        do {
            try interviewService.addInterview(to: jobApplication)
        } catch {
            presentGeneralError()
        }
        
    }

    func deleteInterview(_ interview: Interview) {
        do {
            try interviewService.deleteInterview(interview)
        } catch {
            presentGeneralError()
        }
    }

    func deleteJobApplication(_ jobApplication: JobApplication) {
        do {
            try jobApplicationService.deleteJobApplication(id: jobApplication.persistentModelID)
            coordinator?.pop()
        } catch {
            presentGeneralError()
        }
    }
}

private extension EditJobApplicationViewModel {
    func presentGeneralError() {
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
