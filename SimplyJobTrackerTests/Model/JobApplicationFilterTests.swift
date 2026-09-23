//
//  JobApplicationFilterTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("JobApplicationFilter")
@MainActor
struct JobApplicationFilterTests {

    @Test("a filter with nothing set has no active filters")
    func hasActiveFiltersDefault() async throws {
        let filter = JobApplicationFilter()

        #expect(!filter.hasActiveFilters)
    }

    @Test("picking a status counts as an active filter")
    func hasActiveFiltersStatus() async throws {
        var filter = JobApplicationFilter()
        filter.status = .applied

        #expect(filter.hasActiveFilters)
    }

    @Test("marking favorites-only counts as an active filter")
    func hasActiveFiltersFavorite() async throws {
        var filter = JobApplicationFilter()
        filter.isFavorite = true

        #expect(filter.hasActiveFilters)
    }

    @Test("picking a date counts as an active filter")
    func hasActiveFiltersDate() async throws {
        var filter = JobApplicationFilter()
        filter.dateContainer.selection = .single(Date())

        #expect(filter.hasActiveFilters)
    }
}
