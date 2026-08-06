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
    case passed
    
    var title: String {
        self.rawValue.capitalized
    }
    
    var color: Color {
        switch self {
        case .applied: .blue
        case .interviewing: .yellow
        case .offer: .green
        case .rejected: .gray
        case .passed: .pink.mix(with: .white, by: 0.3)
        }
    }
}
