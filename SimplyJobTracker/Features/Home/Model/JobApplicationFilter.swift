//
//  JobApplicationFilter.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/4/26.
//

import Foundation

struct JobApplicationFilter {
    var status: JobApplicationStatus?
    var dateContainer = DateContainer()
}

struct DateContainer {
    enum Selection {
        case none
        case single(Date)
        case range(ClosedRange<Date>)
    }
    
    var selection: Selection = .none
    
    var singleDate: Date? {
        get { if case .single(let date) = selection { return date }; return nil }
        set { selection = newValue.map(Selection.single) ?? .none }
    }
    
    var dateRange: ClosedRange<Date>? {
        get { if case .range(let range) = selection { return range }; return nil }
        set { selection = newValue.map(Selection.range) ?? .none }
    }
}
