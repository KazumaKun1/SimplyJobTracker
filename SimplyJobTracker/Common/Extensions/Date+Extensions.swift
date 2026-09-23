//
//  Date+CompactRelative.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import Foundation

extension Date {
    func relativeRange(days: Int) -> ClosedRange<Date> {
        let relativeDate = Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
        
        return days >= 0 ? self...relativeDate : relativeDate...self
    }
}


