//
//  EditJobApplicationViewModelTests.swift
//  SimplyJobTrackerTests
//

import SwiftData
import Testing
@testable import SimplyJobTracker

@Suite("EditJobApplicationViewModel")
@MainActor
struct EditJobApplicationViewModelTests {

    @Test("adding an interview from the edit screen actually saves one")
    func addInterviewCallsService() async throws {
        let jobApplicationService = MockJobApplicationService()
        let interviewService = MockInterviewService()
        let coordinator = HomeCoordinator(modelContainer: try previewContainer())
        let viewModel = EditJobApplicationViewModel(jobApplicationService: jobApplicationService, interviewService: interviewService, coordinator: coordinator)
        let jobApplication = JobApplication()

        viewModel.addInterview(to: jobApplication)

        #expect(interviewService.addInterviewCalledWith === jobApplication)
    }

    @Test("a failed interview add is handled gracefully, not a crash")
    func addInterviewThrows() async throws {
        let jobApplicationService = MockJobApplicationService()
        let interviewService = MockInterviewService()
        interviewService.addError = JobTrackerError.generalError
        let coordinator = HomeCoordinator(modelContainer: try previewContainer())
        let viewModel = EditJobApplicationViewModel(jobApplicationService: jobApplicationService, interviewService: interviewService, coordinator: coordinator)

        viewModel.addInterview(to: JobApplication())
    }

    @Test("deleting an interview from the edit screen actually removes it")
    func deleteInterviewCallsService() async throws {
        let jobApplicationService = MockJobApplicationService()
        let interviewService = MockInterviewService()
        let coordinator = HomeCoordinator(modelContainer: try previewContainer())
        let viewModel = EditJobApplicationViewModel(jobApplicationService: jobApplicationService, interviewService: interviewService, coordinator: coordinator)
        let interview = Interview()

        viewModel.deleteInterview(interview)

        #expect(interviewService.deleteInterviewCalledWith === interview)
    }

    @Test("a failed interview delete is handled gracefully, not a crash")
    func deleteInterviewThrows() async throws {
        let jobApplicationService = MockJobApplicationService()
        let interviewService = MockInterviewService()
        interviewService.deleteError = JobTrackerError.generalError
        let coordinator = HomeCoordinator(modelContainer: try previewContainer())
        let viewModel = EditJobApplicationViewModel(jobApplicationService: jobApplicationService, interviewService: interviewService, coordinator: coordinator)

        viewModel.deleteInterview(Interview())
    }

    @Test("deleting the application removes the exact one being edited")
    func deleteApplicationCallsService() async throws {
        let jobApplicationService = MockJobApplicationService()
        let interviewService = MockInterviewService()
        let coordinator = HomeCoordinator(modelContainer: try previewContainer())
        let viewModel = EditJobApplicationViewModel(jobApplicationService: jobApplicationService, interviewService: interviewService, coordinator: coordinator)
        let jobApplication = JobApplication()

        await viewModel.deleteJobApplication(jobApplication)

        let calledWith = await jobApplicationService.deleteJobApplicationCalledWith
        #expect(calledWith == jobApplication.persistentModelID)
    }

    @Test("a failed application delete is handled gracefully, not a crash")
    func deleteApplicationThrows() async throws {
        let jobApplicationService = MockJobApplicationService()
        await jobApplicationService.setDeleteError(JobTrackerError.generalError)
        let interviewService = MockInterviewService()
        let coordinator = HomeCoordinator(modelContainer: try previewContainer())
        let viewModel = EditJobApplicationViewModel(jobApplicationService: jobApplicationService, interviewService: interviewService, coordinator: coordinator)

        await viewModel.deleteJobApplication(JobApplication())
    }
}
