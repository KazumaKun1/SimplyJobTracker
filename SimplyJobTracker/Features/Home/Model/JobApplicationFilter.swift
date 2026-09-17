//
//  JobApplicationFilter.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/4/26.
//

import Foundation

struct JobApplicationFilter {
    var status: JobApplicationStatus?
    var isFavorite: Bool?
    var dateContainer = DateContainer()

    var hasActiveFilters: Bool {
        status != nil || isFavorite != nil || dateContainer.isActive
    }
}

struct DateContainer {
    enum Selection {
        case none
        case single(Date)
        case range(ClosedRange<Date>)
    }

    var selection: Selection = .none
    var rangePreset: DateRangeSelection?

    var isActive: Bool {
        if case .none = selection { return false }
        return true
    }

    var singleDate: Date? {
        get { if case .single(let date) = selection { return date }; return nil }
        set {
            selection = newValue.map(Selection.single) ?? .none
            if case .none = selection {
                rangePreset = nil
            }
        }
    }

    var dateRange: ClosedRange<Date>? {
        get { if case .range(let range) = selection { return range }; return nil }
        set {
            selection = newValue.map(Selection.range) ?? .none
            if case .none = selection {
                rangePreset = nil
            }
        }
    }
    
    var isSelectionSingleDate: Bool {
        if case .single = selection { return true }
        return false
    }

    mutating func selectPreset(_ preset: DateRangeSelection) {
        if rangePreset == preset { // Selecting the same preset will unselect it
            rangePreset = nil
            selection = .none
        } else { // Selecting a different preset will select the currently selected preset
            rangePreset = preset
            if preset == .custom {
                selection = .single(Date())
            } else {
                selection = preset.dateRangeAgo.map(Selection.range) ?? .none
            }
        }
    }
}

enum DateRangeSelection: CaseIterable, Identifiable {
    case sevenDays
    case fourteenDays
    case thirtyDays
    case custom

    var id: Self { self }

    var title: String {
        switch self {
        case .sevenDays: "Last 7 days"
        case .fourteenDays: "Last 14 days"
        case .thirtyDays: "Last 30 days"
        case .custom: "Custom"
        }
    }

    var dateRangeAgo: ClosedRange<Date>? {
        switch self {
        case .sevenDays: Date().relativeRange(days: -7)
        case .fourteenDays: Date().relativeRange(days: -14)
        case .thirtyDays: Date().relativeRange(days: -30)
        case .custom: nil
        }
    }
}
