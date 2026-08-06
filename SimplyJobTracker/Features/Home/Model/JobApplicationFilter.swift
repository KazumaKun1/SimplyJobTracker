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
    var singleDate: Date?
    var dateRange: ClosedRange<Date>?
}
