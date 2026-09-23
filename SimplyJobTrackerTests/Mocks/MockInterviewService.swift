//
//  MockInterviewService.swift
//  SimplyJobTrackerTests
//

@testable import SimplyJobTracker

final class MockInterviewService: InterviewService {
    var addInterviewCalledWith: JobApplication?
    var deleteInterviewCalledWith: Interview?
    var addError: Error?
    var deleteError: Error?

    func addInterview(to jobApplication: JobApplication) throws {
        addInterviewCalledWith = jobApplication
        if let addError { throw addError }
    }

    func deleteInterview(_ interview: Interview) throws {
        deleteInterviewCalledWith = interview
        if let deleteError { throw deleteError }
    }
}
