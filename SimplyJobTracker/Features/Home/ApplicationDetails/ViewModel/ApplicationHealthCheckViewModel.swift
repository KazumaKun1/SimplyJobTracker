//
//  ApplicationHealthCheckViewModel.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import Foundation

@available(iOS 26.0, *)
@Observable
class ApplicationHealthCheckViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(ApplicationHealthAssessment)
        case failed
    }

    private(set) var state: State = .idle

    private let service: ApplicationHealthCheckService
    private let jobApplication: JobApplication

    init(service: ApplicationHealthCheckService, jobApplication: JobApplication) {
        self.service = service
        self.jobApplication = jobApplication
    }

    func runAssessment() async {
        state = .loading
        do {
            let input = ApplicationHealthCheckInput(jobApplication: jobApplication)
            state = .loaded(try await service.assessHealth(for: input))
        } catch {
            state = .failed
        }
    }
}
