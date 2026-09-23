//
//  InterviewServiceImplTests.swift
//  SimplyJobTrackerTests
//

import SwiftData
import Testing
@testable import SimplyJobTracker

@Suite("InterviewServiceImpl")
@MainActor
struct InterviewServiceImplTests {

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: JobApplication.self, Interview.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    @Test("adding an interview attaches it to the application and saves it")
    func addsInterview() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)
        try service.addInterview(to: jobApplication)

        #expect(jobApplication.interviews.count == 1)
        let interviews = try context.fetch(FetchDescriptor<Interview>())
        #expect(interviews.count == 1)
    }

    @Test("deleting an interview removes it from the application entirely")
    func deletesInterview() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)
        try service.addInterview(to: jobApplication)
        let interview = try #require(jobApplication.interviews.first)

        try service.deleteInterview(interview)

        #expect(jobApplication.interviews.isEmpty)
        let interviews = try context.fetch(FetchDescriptor<Interview>())
        #expect(interviews.isEmpty)
    }
}
