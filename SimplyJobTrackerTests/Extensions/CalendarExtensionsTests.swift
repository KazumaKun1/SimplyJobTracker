//
//  CalendarExtensionsTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("Calendar+Extensions")
@MainActor
struct CalendarExtensionsTests {

    @Test("there are no components to give back for a date that isn't there")
    func componentsFromNilDate() async throws {
        let components = Calendar.current.components(from: nil as Date?)

        #expect(components == nil)
    }

    @Test("a real date breaks down into the matching year, month, and day")
    func componentsFromDate() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 15))!

        let components = calendar.components(from: date)

        #expect(components?.year == 2026)
        #expect(components?.month == 3)
        #expect(components?.day == 15)
    }

    @Test("there's nothing to list for a range that isn't there")
    func componentsFromNilRange() async throws {
        let components = Calendar.current.components(from: nil as ClosedRange<Date>?)

        #expect(components.isEmpty)
    }

    @Test("a date range expands into one entry for every day it covers, including both ends")
    func componentsFromRange() async throws {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 3, day: 4))!

        let components = calendar.components(from: start...end)

        #expect(components.count == 4)
        #expect(components.map(\.day) == [1, 2, 3, 4])
    }

    @Test("a range that starts and ends on the same day expands into just that one day")
    func componentsFromSingleDayRange() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))!

        let components = calendar.components(from: date...date)

        #expect(components.count == 1)
    }
}
