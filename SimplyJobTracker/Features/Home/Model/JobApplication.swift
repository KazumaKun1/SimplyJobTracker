//
//  JobApplication.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/2/26.
//

import Foundation
import SwiftData

@Model
class JobApplication {
    @Attribute(.unique) var id: UUID = UUID()
    var status: JobApplicationStatus
    var role: String?
    var company: String?
    var overallExperience: String?
    var rating: Int?
    var feeling: String?
    var date: Date
    var isFavorite: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \Interview.jobApplication)
    var interviews: [Interview] = []
    
    init(status: JobApplicationStatus = .applied, isFavorite: Bool = false) {
        self.id = UUID()
        self.status = status
        self.date = .now
        self.isFavorite = isFavorite
    }
}
