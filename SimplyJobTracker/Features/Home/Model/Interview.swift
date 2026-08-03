//
//  Interview.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import Foundation
import SwiftData

@Model
class Interview {
    // Back reference to parent
    var jobApplication: JobApplication?
    
    var title: String?
    var date: Date
    var descriptionContent: String?
    
    init() {
        self.date = .now
    }
}
