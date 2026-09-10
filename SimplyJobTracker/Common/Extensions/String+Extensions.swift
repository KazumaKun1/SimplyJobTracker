//
//  String+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/8/26.
//

import SwiftUI

extension String? {
    var nilIfEmpty: String? {
        self?.isEmpty == false ? self : nil
    }
}
