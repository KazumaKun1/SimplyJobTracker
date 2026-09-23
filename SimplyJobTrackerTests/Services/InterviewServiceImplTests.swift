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

    @Test("adding an interview after a middle one was deleted does not collide with an existing sort order")
    func addsInterviewAfterMiddleDeleteWithoutCollision() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)
        try service.addInterview(to: jobApplication)
        try service.addInterview(to: jobApplication)
        try service.addInterview(to: jobApplication)
        let ordered = jobApplication.interviews.sorted(by: Interview.orderedComparator)
        try service.deleteInterview(ordered[1])

        try service.addInterview(to: jobApplication)

        let sortOrders = jobApplication.interviews.map(\.sortOrder)
        #expect(sortOrders.count == Set(sortOrders).count)
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

    @Test("moving an interview up swaps its sort order with the previous interview")
    func movesInterviewUp() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)
        try service.addInterview(to: jobApplication)
        try service.addInterview(to: jobApplication)
        let ordered = jobApplication.interviews.sorted(by: Interview.orderedComparator)
        let first = ordered[0]
        let second = ordered[1]

        try service.moveInterview(second, in: jobApplication, direction: .up)

        #expect(second.sortOrder == 0)
        #expect(first.sortOrder == 1)
    }

    @Test("moving the first interview up is a no-op")
    func movingFirstInterviewUpDoesNothing() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)
        try service.addInterview(to: jobApplication)
        try service.addInterview(to: jobApplication)
        let first = try #require(jobApplication.interviews.sorted(by: Interview.orderedComparator).first)

        try service.moveInterview(first, in: jobApplication, direction: .up)

        #expect(first.sortOrder == 0)
    }

    @Test("moving the last interview down is a no-op")
    func movingLastInterviewDownDoesNothing() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)
        try service.addInterview(to: jobApplication)
        try service.addInterview(to: jobApplication)
        let last = try #require(jobApplication.interviews.sorted(by: Interview.orderedComparator).last)

        try service.moveInterview(last, in: jobApplication, direction: .down)

        #expect(last.sortOrder == 1)
    }

    @Test("moving an interview reorders it even when existing sort orders are tied")
    func movesInterviewDespiteTiedSortOrders() async throws {
        let context = try makeContext()
        let jobApplication = JobApplication()
        context.insert(jobApplication)
        try context.save()

        let first = Interview()
        let second = Interview()
        let third = Interview()
        context.insert(first)
        context.insert(second)
        context.insert(third)
        jobApplication.interviews = [first, second, third]
        try context.save()

        let service = InterviewServiceImpl(modelContext: context)

        let before = jobApplication.interviews.sorted(by: Interview.orderedComparator)
        let moved = before[1]
        let neighbor = before[2]

        try service.moveInterview(moved, in: jobApplication, direction: .down)

        let after = jobApplication.interviews.sorted(by: Interview.orderedComparator)
        #expect(after[1].persistentModelID == neighbor.persistentModelID)
        #expect(after[2].persistentModelID == moved.persistentModelID)
        #expect(Set(after.map(\.sortOrder)).count == after.count)
    }
}
