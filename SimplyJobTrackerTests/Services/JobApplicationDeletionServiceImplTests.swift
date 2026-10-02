//
//  JobApplicationDeletionServiceImplTests.swift
//  SimplyJobTrackerTests
//

import SwiftData
import Testing
@testable import SimplyJobTracker

@Suite("JobApplicationDeletionServiceImpl")
@MainActor
struct JobApplicationDeletionServiceImplTests {

    private func makeContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: JobApplication.self, Interview.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    @Test("deleting an application removes it from storage")
    func deletesApplication() throws {
        let context = try makeContext()
        let application = JobApplication()
        context.insert(application)
        try context.save()

        try JobApplicationDeletionServiceImpl(modelContext: context).deleteJobApplication(application)

        #expect(try context.fetch(FetchDescriptor<JobApplication>()).isEmpty)
    }

    @Test("deleting an application with unsaved edits still removes it")
    func deletesApplicationWithUnsavedEdits() throws {
        let context = try makeContext()
        let application = JobApplication()
        context.insert(application)
        try context.save()
        application.role = "Engineer"

        try JobApplicationDeletionServiceImpl(modelContext: context).deleteJobApplication(application)

        #expect(try context.fetch(FetchDescriptor<JobApplication>()).isEmpty)
    }
}
