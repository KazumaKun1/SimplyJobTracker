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

    private let jobApplicationDeletionService: JobApplicationDeletionService
    private let interviewService: InterviewService

    init(jobApplicationDeletionService: JobApplicationDeletionService, interviewService: InterviewService, coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        self.jobApplicationDeletionService = jobApplicationDeletionService
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

    func moveInterview(_ interview: Interview, in jobApplication: JobApplication, direction: InterviewMoveDirection) {
        do {
            try interviewService.moveInterview(interview, in: jobApplication, direction: direction)
        } catch {
            presentGeneralError()
        }
    }

    func deleteJobApplication(_ jobApplication: JobApplication) {
        do {
            try jobApplicationDeletionService.deleteJobApplication(jobApplication)
            coordinator?.popToRoot()
        } catch {
            presentGeneralError()
        }
    }
}

extension EditJobApplicationViewModel {
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

// MARK: - Navigation
extension EditJobApplicationViewModel {
    func showEditJobApplication(for jobApplication: JobApplication) {
        coordinator?.navigate(to: .editApplication(jobApplication))
    }
}
