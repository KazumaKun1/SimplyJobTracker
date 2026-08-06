//
//  FormatStyle+CompactRelative.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import SwiftUI

struct CompactRelativeFormatStyle: FormatStyle {
    func format(_ value: Date) -> String {
        value.compactRelativeString()
    }
}

extension FormatStyle where Self == CompactRelativeFormatStyle {
    static var compactRelative: CompactRelativeFormatStyle {
        CompactRelativeFormatStyle()
    }
}
