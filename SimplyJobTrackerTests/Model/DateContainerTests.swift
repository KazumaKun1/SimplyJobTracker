//
//  DateContainerTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import Testing
@testable import SimplyJobTracker

@Suite("DateContainer")
@MainActor
struct DateContainerTests {

    @Test("no date is selected by default")
    func isActiveNone() async throws {
        let container = DateContainer()

        #expect(!container.isActive)
    }

    @Test("picking a single day makes the container active")
    func isActiveSingle() async throws {
        var container = DateContainer()
        container.selection = .single(Date())

        #expect(container.isActive)
    }

    @Test("picking a date range makes the container active")
    func isActiveRange() async throws {
        var container = DateContainer()
        container.selection = .range(Date()...Date())

        #expect(container.isActive)
    }

    @Test("setting a single date switches the container into single-date mode")
    func setSingleDate() async throws {
        var container = DateContainer()
        let date = Date()
        container.singleDate = date

        #expect(container.singleDate == date)
        #expect(container.isSelectionSingleDate)
    }

    @Test("clearing the single date turns the container off entirely, including any preset")
    func clearSingleDate() async throws {
        var container = DateContainer()
        container.selectPreset(.sevenDays)
        container.singleDate = Date()
        container.singleDate = nil

        #expect(!container.isActive)
        #expect(container.rangePreset == nil)
    }

    @Test("asking for a single date while a range is selected gives nothing")
    func singleDateOnRange() async throws {
        var container = DateContainer()
        container.selection = .range(Date()...Date())

        #expect(container.singleDate == nil)
    }

    @Test("setting a date range switches the container into range mode")
    func setDateRange() async throws {
        var container = DateContainer()
        let range = Date()...Date().addingTimeInterval(86400)
        container.dateRange = range

        #expect(container.dateRange == range)
        #expect(!container.isSelectionSingleDate)
    }

    @Test("clearing the date range turns the container off entirely, including any preset")
    func clearDateRange() async throws {
        var container = DateContainer()
        container.selectPreset(.sevenDays)
        container.dateRange = nil

        #expect(!container.isActive)
        #expect(container.rangePreset == nil)
    }

    @Test("asking for a date range while a single date is selected gives nothing")
    func dateRangeOnSingle() async throws {
        var container = DateContainer()
        container.selection = .single(Date())

        #expect(container.dateRange == nil)
    }

    @Test("single-date mode is only reported for an actual single-date selection")
    func isSelectionSingleDate() async throws {
        var container = DateContainer()
        container.selection = .single(Date())
        #expect(container.isSelectionSingleDate)

        container.selection = .range(Date()...Date())
        #expect(!container.isSelectionSingleDate)

        container.selection = .none
        #expect(!container.isSelectionSingleDate)
    }

    @Test("picking a preset like 'last 7 days' fills in the matching date range")
    func selectPresetFromNone() async throws {
        var container = DateContainer()
        container.selectPreset(.sevenDays)

        #expect(container.rangePreset == .sevenDays)
        let range = try #require(container.dateRange)
        let dayDifference = Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day
        #expect(dayDifference == 7)
    }

    @Test("tapping the same preset again deselects it")
    func selectPresetToggleOff() async throws {
        var container = DateContainer()
        container.selectPreset(.sevenDays)
        container.selectPreset(.sevenDays)

        #expect(container.rangePreset == nil)
        #expect(!container.isActive)
    }

    @Test("the custom preset opens a single-date picker instead of a fixed range")
    func selectPresetCustom() async throws {
        var container = DateContainer()
        container.selectPreset(.custom)

        #expect(container.rangePreset == .custom)
        #expect(container.isSelectionSingleDate)
    }

    @Test("switching to a different preset replaces the previous range")
    func selectPresetSwitch() async throws {
        var container = DateContainer()
        container.selectPreset(.sevenDays)
        container.selectPreset(.fourteenDays)

        #expect(container.rangePreset == .fourteenDays)
        let range = try #require(container.dateRange)
        let dayDifference = Calendar.current.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day
        #expect(dayDifference == 14)
    }
}
