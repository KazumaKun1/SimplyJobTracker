//
//  String+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/8/26.
//

import SwiftUI

extension Binding where Value == String? {
    func unwrapped(with fallback: String = "") -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? fallback },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

extension Binding where Value == Date? {
    func unwrapped(with fallback: Date = .now) -> Binding<Date> {
        Binding<Date>(
            get: { self.wrappedValue ?? fallback },
            set: { self.wrappedValue = $0 }
        )
    }
}
