//
//  JobApplicationExportRowTests.swift
//  SimplyJobTrackerTests
//

import Testing
@testable import SimplyJobTracker

@Suite("JobApplicationExportRow")
@MainActor
struct JobApplicationExportRowTests {

    @Test("a job application with no role or company exports those fields as blank")
    func nilRoleAndCompany() async throws {
        let jobApplication = JobApplication()
        jobApplication.role = nil
        jobApplication.company = nil

        let row = JobApplicationExportRow(from: jobApplication)

        #expect(row.role == "")
        #expect(row.company == "")
    }

    @Test("an unrated application exports its rating as blank")
    func nilRating() async throws {
        let jobApplication = JobApplication()
        jobApplication.rating = nil

        let row = JobApplicationExportRow(from: jobApplication)

        #expect(row.rating == "")
    }

    @Test("a rated application exports its rating as plain text")
    func ratingStringified() async throws {
        let jobApplication = JobApplication()
        jobApplication.rating = 4

        let row = JobApplicationExportRow(from: jobApplication)

        #expect(row.rating == "4")
    }

    @Test("the exported interview count matches how many interviews were logged")
    func interviewCount() async throws {
        let jobApplication = JobApplication()
        jobApplication.interviews = [Interview(), Interview(), Interview()]

        let row = JobApplicationExportRow(from: jobApplication)

        #expect(row.interviewCount == 3)
    }
}
