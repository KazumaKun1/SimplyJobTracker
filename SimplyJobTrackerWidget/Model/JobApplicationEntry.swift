//
//  JobApplicationEntry.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import WidgetKit
import SwiftUI

struct JobApplicationEntry: TimelineEntry {
    let date: Date
    let numberOfApplied: Int
    let numberOfInterviewing: Int
    let numberOfOffers: Int
    let numberOfRejected: Int
    let numberOfGhosted: Int
    
    var total: Int {
        numberOfApplied + numberOfInterviewing + numberOfOffers + numberOfRejected + numberOfGhosted
    }
}
