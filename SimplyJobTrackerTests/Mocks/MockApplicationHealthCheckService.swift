//
//  MockApplicationHealthCheckService.swift
//  SimplyJobTrackerTests
//

@testable import SimplyJobTracker

@available(iOS 26.0, *)
@MainActor
final class MockApplicationHealthCheckService: ApplicationHealthCheckService {
    var result: ApplicationHealthAssessment?
    var error: Error?

    func assessHealth(for input: ApplicationHealthCheckInput) async throws -> ApplicationHealthAssessment {
        if let error { throw error }
        guard let result else { throw ApplicationHealthCheckError.generationFailed }
        return result
    }
}
