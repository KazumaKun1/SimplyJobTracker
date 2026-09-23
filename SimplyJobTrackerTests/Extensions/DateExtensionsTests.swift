//
//  DateExtensionsTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("Date+Extensions")
@MainActor
struct DateExtensionsTests {

    @Test("a range some days into the future starts today and ends on that future day")
    func relativeRangePositiveDays() async throws {
        let date = Date()
        let range = date.relativeRange(days: 5)
        let expectedUpperBound = Calendar.current.date(byAdding: .day, value: 5, to: date)!

        #expect(range.lowerBound == date)
        #expect(range.upperBound == expectedUpperBound)
    }

    @Test("a range some days into the past starts on that past day and ends today")
    func relativeRangeNegativeDays() async throws {
        let date = Date()
        let range = date.relativeRange(days: -5)
        let expectedLowerBound = Calendar.current.date(byAdding: .day, value: -5, to: date)!

        #expect(range.lowerBound == expectedLowerBound)
        #expect(range.upperBound == date)
    }

    @Test("a zero-day range collapses to a single point in time")
    func relativeRangeZeroDays() async throws {
        let date = Date()
        let range = date.relativeRange(days: 0)

        #expect(range.lowerBound == date)
        #expect(range.upperBound == date)
    }
}
