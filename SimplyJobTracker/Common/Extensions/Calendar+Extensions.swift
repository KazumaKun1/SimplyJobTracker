//
//  Calendar+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/8/26.
//

import Foundation

extension Calendar {
    func components(from date: Date?) -> DateComponents? {
        guard let date else { return nil }
        return dateComponents([.year, .month, .day], from: date)
    }
    
    func components(from range: ClosedRange<Date>?) -> [DateComponents] {
        guard let range else { return [] }
        var componentsList: [DateComponents] = []
        
        var currentDate = range.lowerBound
        while currentDate <= range.upperBound {
            let component = dateComponents([.year, .month, .day], from: currentDate)
            componentsList.append(component)
            
            guard let nextDate = date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return componentsList
    }
}
