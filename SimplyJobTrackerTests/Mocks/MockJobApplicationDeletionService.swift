//
//  MockJobApplicationDeletionService.swift
//  SimplyJobTrackerTests
//

@testable import SimplyJobTracker

final class MockJobApplicationDeletionService: JobApplicationDeletionService {
    var deleteCalledWith: JobApplication?
    var deleteError: Error?

    func deleteJobApplication(_ jobApplication: JobApplication) throws {
        deleteCalledWith = jobApplication
        if let deleteError { throw deleteError }
    }
}
