//
//  JobApplicationStatus.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/2/26.
//

import SwiftUI

enum JobApplicationStatus: String, CaseIterable, Codable {
    case applied
    case interviewing
    case offer
    case rejected
    case ghosted
    
    var title: String {
        self.rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .applied: .applied
        case .interviewing: .interviewing
        case .offer: .offers
        case .rejected: .rejected
        case .ghosted: .ghosted
        }
    }
}
