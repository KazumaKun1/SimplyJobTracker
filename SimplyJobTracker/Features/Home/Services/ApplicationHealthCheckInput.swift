//
//  ApplicationHealthCheckInput.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import Foundation

struct ApplicationHealthCheckInput {
    struct InterviewSnapshot {
        let title: String?
        let daysSince: Int
        let description: String?
    }

    let status: String
    let daysSinceApplied: Int
    let interviews: [InterviewSnapshot]
    let rating: Int?
    let feeling: String?
    let notes: String?

    init(jobApplication: JobApplication) {
        let calendar = Calendar.current
        
        status = jobApplication.status.rawValue
        daysSinceApplied = calendar.dateComponents([.day], from: jobApplication.date, to: .now).day ?? 0
        interviews = jobApplication.interviews
            .sorted { $0.date < $1.date }
            .map {
                InterviewSnapshot(
                    title: $0.title.nilIfEmpty,
                    daysSince: calendar.dateComponents([.day], from: $0.date, to: .now).day ?? 0,
                    description: $0.descriptionContent.nilIfEmpty
                )
            }
        rating = jobApplication.rating
        feeling = jobApplication.feeling.nilIfEmpty
        notes = jobApplication.overallExperience.nilIfEmpty
    }
}
