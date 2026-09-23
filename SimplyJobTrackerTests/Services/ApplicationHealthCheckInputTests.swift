//
//  ApplicationHealthCheckInputTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("ApplicationHealthCheckInput")
@MainActor
struct ApplicationHealthCheckInputTests {

    @Test("the health check knows how many days ago the application was submitted")
    func daysSinceApplied() async throws {
        let jobApplication = JobApplication()
        jobApplication.date = Calendar.current.date(byAdding: .day, value: -10, to: .now)!

        let input = ApplicationHealthCheckInput(jobApplication: jobApplication)

        #expect(input.daysSinceApplied == 10)
    }

    @Test("interviews reach the health check oldest first, no matter how they were logged")
    func interviewsSorted() async throws {
        let jobApplication = JobApplication()
        let older = Interview()
        older.title = "Older"
        older.date = Calendar.current.date(byAdding: .day, value: -20, to: .now)!
        let newer = Interview()
        newer.title = "Newer"
        newer.date = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        jobApplication.interviews = [newer, older]

        let input = ApplicationHealthCheckInput(jobApplication: jobApplication)

        #expect(input.interviews.map(\.title) == ["Older", "Newer"])
    }

    @Test("each interview reports how many days ago it happened")
    func interviewDaysSince() async throws {
        let jobApplication = JobApplication()
        let interview = Interview()
        interview.date = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        jobApplication.interviews = [interview]

        let input = ApplicationHealthCheckInput(jobApplication: jobApplication)

        #expect(input.interviews.first?.daysSince == 5)
    }

    @Test(
        "blank notes, feelings, and interview details are treated as not provided",
        arguments: ["title", "descriptionContent", "feeling", "overallExperience"]
    )
    func emptyFieldMapsToNil(fieldName: String) async throws {
        let jobApplication = JobApplication()
        jobApplication.feeling = ""
        jobApplication.overallExperience = ""
        let interview = Interview()
        interview.title = ""
        interview.descriptionContent = ""
        jobApplication.interviews = [interview]

        let input = ApplicationHealthCheckInput(jobApplication: jobApplication)

        switch fieldName {
        case "title":
            #expect(input.interviews.first?.title == nil)
        case "descriptionContent":
            #expect(input.interviews.first?.description == nil)
        case "feeling":
            #expect(input.feeling == nil)
        case "overallExperience":
            #expect(input.notes == nil)
        default:
            Issue.record("Unexpected field name: \(fieldName)")
        }
    }

    @Test("a given rating reaches the health check unchanged")
    func ratingPassthrough() async throws {
        let jobApplication = JobApplication()
        jobApplication.rating = 4

        let input = ApplicationHealthCheckInput(jobApplication: jobApplication)

        #expect(input.rating == 4)
    }

    @Test("no rating reaches the health check as no rating")
    func nilRatingPassthrough() async throws {
        let jobApplication = JobApplication()
        jobApplication.rating = nil

        let input = ApplicationHealthCheckInput(jobApplication: jobApplication)

        #expect(input.rating == nil)
    }
}
