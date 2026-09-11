//
//  URL+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/11/26.
//

import Foundation

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
