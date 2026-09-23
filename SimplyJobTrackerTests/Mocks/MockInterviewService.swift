//
//  MockInterviewService.swift
//  SimplyJobTrackerTests
//

@testable import SimplyJobTracker

final class MockInterviewService: InterviewService {
    var addInterviewCalledWith: JobApplication?
    var deleteInterviewCalledWith: Interview?
    var moveInterviewCalledWith: (interview: Interview, jobApplication: JobApplication, direction: InterviewMoveDirection)?
    var addError: Error?
    var deleteError: Error?
    var moveError: Error?

    func addInterview(to jobApplication: JobApplication) throws {
        addInterviewCalledWith = jobApplication
        if let addError { throw addError }
    }

    func deleteInterview(_ interview: Interview) throws {
        deleteInterviewCalledWith = interview
        if let deleteError { throw deleteError }
    }

    func moveInterview(_ interview: Interview, in jobApplication: JobApplication, direction: InterviewMoveDirection) throws {
        moveInterviewCalledWith = (interview, jobApplication, direction)
        if let moveError { throw moveError }
    }
}
