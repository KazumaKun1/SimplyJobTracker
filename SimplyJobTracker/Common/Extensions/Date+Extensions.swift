//
//  Date+CompactRelative.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import Foundation

extension Date {
    /// A compact relative time string, e.g. "now", "5m", "3h", "2d", "1w", "4mo".
    ///
    /// Pass a `referenceDate` that changes over time (such as a `TimelineView` tick's
    /// `context.date`) rather than relying on the default `.now` when the result needs
    /// to keep updating — SwiftUI only re-renders `Text` when its inputs actually change,
    /// so a fixed/implicit "now" captured elsewhere won't trigger a redraw on its own.
    func compactRelativeString(to referenceDate: Date = .now) -> String {
        let seconds = Int(referenceDate.timeIntervalSince(self))
        switch seconds {
        case ..<60:      return "now"
        case ..<3600:    return "\(seconds / 60)m"
        case ..<86400:   return "\(seconds / 3600)h"
        case ..<604800:  return "\(seconds / 86400)d"
        case ..<2419200: return "\(seconds / 604800)w"
        default:         return "\(seconds / 2419200)mo"
        }
    }
    
    func relativeRange(days: Int) -> ClosedRange<Date> {
        let relativeDate = Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
        
        return days >= 0 ? self...relativeDate : relativeDate...self
    }
}


