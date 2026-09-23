//
//  ApplicationHealthCheckViewModelTests.swift
//  SimplyJobTrackerTests
//

import Testing
@testable import SimplyJobTracker

@Suite("ApplicationHealthCheckViewModel")
@MainActor
struct ApplicationHealthCheckViewModelTests {

    @available(iOS 26.0, *)
    @Test("running a health check ends with the AI's assessment ready to show")
    func runAssessmentSuccess() async throws {
        let service = MockApplicationHealthCheckService()
        let assessment = ApplicationHealthAssessment(
            status: .steady,
            summary: "Looking steady",
            suggestedNextAction: "Follow up next week"
        )
        service.result = assessment
        let viewModel = ApplicationHealthCheckViewModel(service: service, jobApplication: JobApplication())

        #expect(viewModel.state == .idle)

        await viewModel.runAssessment()

        #expect(viewModel.state == .loaded(assessment))
    }

    @available(iOS 26.0, *)
    @Test("a failed health check surfaces as a clear failure, not a crash")
    func runAssessmentFailure() async throws {
        let service = MockApplicationHealthCheckService()
        service.error = ApplicationHealthCheckError.generationFailed
        let viewModel = ApplicationHealthCheckViewModel(service: service, jobApplication: JobApplication())

        await viewModel.runAssessment()

        #expect(viewModel.state == .failed)
    }
}
