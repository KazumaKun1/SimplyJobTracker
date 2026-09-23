//
//  DateRangeSelectionTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("DateRangeSelection")
@MainActor
struct DateRangeSelectionTests {

    @Test(
        "each named preset spans exactly the number of days it advertises",
        arguments: [
            (DateRangeSelection.sevenDays, 7),
            (DateRangeSelection.fourteenDays, 14),
            (DateRangeSelection.thirtyDays, 30)
        ]
    )
    func dateRangeAgoSpan(preset: DateRangeSelection, days: Int) async throws {
        let range = try #require(preset.dateRangeAgo)
        let dayDifference = Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day

        #expect(dayDifference == days)
    }

    @Test("the custom preset has no fixed range of its own")
    func dateRangeAgoCustom() async throws {
        #expect(DateRangeSelection.custom.dateRangeAgo == nil)
    }
}
