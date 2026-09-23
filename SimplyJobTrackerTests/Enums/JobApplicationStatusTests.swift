//
//  JobApplicationStatusTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("JobApplicationStatus")
struct JobApplicationStatusTests {

    @Test("each status displays with a capitalized title", arguments: JobApplicationStatus.allCases)
    func statusTitle(status: JobApplicationStatus) async throws {
        #expect(status.title == status.rawValue.capitalized)
    }

    @Test("every status has a Siri-facing display name", arguments: JobApplicationStatus.allCases)
    func statusDisplayRepresentation(status: JobApplicationStatus) async throws {
        #expect(JobApplicationStatus.caseDisplayRepresentations[status] != nil)
    }
}
