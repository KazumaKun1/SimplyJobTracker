//
//  JobApplicationServiceImplTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import SimplyJobTracker

@Suite("JobApplicationServiceImpl")
struct JobApplicationServiceImplTests {

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: JobApplication.self, Interview.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test("adding a blank application saves it as 'applied' and it shows up right away")
    func createsDefaultApplication() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)

        try await service.createJobApplication()

        let context = ModelContext(container)
        let applications = try context.fetch(FetchDescriptor<JobApplication>())
        #expect(applications.count == 1)
        #expect(applications.first?.status == .applied)
    }

    @Test("adding an application from Siri's input saves its role, company, and status")
    func createsApplicationWithInput() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)

        try await service.createJobApplication(NewJobApplicationInput(role: "Engineer", company: "Acme", status: .interviewing))

        let context = ModelContext(container)
        let application = try context.fetch(FetchDescriptor<JobApplication>()).first
        #expect(application?.role == "Engineer")
        #expect(application?.company == "Acme")
        #expect(application?.status == .interviewing)
    }

    @Test("deleting an application removes it from storage")
    func deletesApplication() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication()

        let context = ModelContext(container)
        let application = try #require(try context.fetch(FetchDescriptor<JobApplication>()).first)

        try await service.deleteJobApplication(id: application.persistentModelID)

        let remaining = try context.fetch(FetchDescriptor<JobApplication>())
        #expect(remaining.isEmpty)
    }

    @Test("deleting something that isn't a job application fails clearly instead of silently doing nothing")
    func deleteMissingThrows() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)

        let context = ModelContext(container)
        let interview = Interview()
        context.insert(interview)
        try context.save()

        await #expect(throws: JobApplicationServiceError.notFound) {
            try await service.deleteJobApplication(id: interview.persistentModelID)
        }
    }

    @Test("erasing all data leaves nothing behind, no matter how many applications existed")
    func deletesAllApplications() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication()
        try await service.createJobApplication()

        try await service.deleteAllJobApplications()

        let context = ModelContext(container)
        let applications = try context.fetch(FetchDescriptor<JobApplication>())
        #expect(applications.isEmpty)
    }

    @Test("asking for a count with no status filter counts everything")
    func countsAllApplications() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication()
        try await service.createJobApplication()

        let count = try await service.countApplications(status: nil)

        #expect(count == 2)
    }

    @Test("asking for a count by status only counts applications with that status")
    func countsByStatus() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication(NewJobApplicationInput(role: "", company: "", status: .offer))
        try await service.createJobApplication(NewJobApplicationInput(role: "", company: "", status: .applied))

        let count = try await service.countApplications(status: .offer)

        #expect(count == 1)
    }

    @Test("asking for a count by a status nothing has gives zero")
    func countsByStatusZero() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication()

        let count = try await service.countApplications(status: .rejected)

        #expect(count == 0)
    }

    @Test("the latest application is whichever one was applied to most recently, not just last created")
    func latestApplication() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication(NewJobApplicationInput(role: "Old", company: "X", status: .applied))

        let context = ModelContext(container)
        let oldApplication = try #require(try context.fetch(FetchDescriptor<JobApplication>()).first)
        oldApplication.date = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        try context.save()

        try await service.createJobApplication(NewJobApplicationInput(role: "New", company: "Y", status: .offer))

        let latest = try await service.getLatestApplication()

        #expect(latest?.role == "New")
    }

    @Test("there's no latest application when none exist yet")
    func latestApplicationEmpty() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)

        let latest = try await service.getLatestApplication()

        #expect(latest == nil)
    }

    @Test("exporting with nothing to export fails clearly instead of producing an empty file")
    func exportEmptyThrows() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)

        await #expect(throws: JobApplicationServiceError.emptyRecords) {
            try await service.exportCSVFile()
        }
    }

    @Test("the exported CSV lists applications oldest first and matches the CSV formatter's output")
    func exportMatchesCSV() async throws {
        let container = try makeContainer()
        let service = JobApplicationServiceImpl(modelContainer: container)
        try await service.createJobApplication(NewJobApplicationInput(role: "Engineer", company: "Acme", status: .applied))

        let url = try await service.exportCSVFile()
        defer { try? FileManager.default.removeItem(at: url) }
        let contents = try String(contentsOf: url, encoding: .utf8)

        let context = ModelContext(container)
        let applications = try context.fetch(FetchDescriptor<JobApplication>(sortBy: [SortDescriptor(\.date)]))
        let expected = CSVExporter.makeCSV(from: applications.map(JobApplicationExportRow.init))

        #expect(contents == expected)
    }
}
