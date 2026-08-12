//
//  Binding+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/8/26.
//

import SwiftUI

extension Binding {
    func toOptional(fallback: Value) -> Binding<Value?>{
        Binding<Value?>(
            get: { wrappedValue },
            set: { newValue in
                wrappedValue = newValue ?? fallback
            }
        )
    }
}
