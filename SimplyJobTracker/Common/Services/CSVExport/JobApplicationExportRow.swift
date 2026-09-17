//
//  JobApplicationExportRow.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/11/26.
//

import Foundation

struct JobApplicationExportRow {
    let status: String
    let role: String
    let company: String
    let overallExperience: String
    let rating: String
    let feeling: String
    let date: Date
    let isFavorite: Bool
    let interviewCount: Int

    nonisolated init(from jobApplication: JobApplication) {
        status = jobApplication.status.rawValue
        role = jobApplication.role ?? ""
        company = jobApplication.company ?? ""
        overallExperience = jobApplication.overallExperience ?? ""
        rating = jobApplication.rating.map(String.init) ?? ""
        feeling = jobApplication.feeling ?? ""
        date = jobApplication.date
        isFavorite = jobApplication.isFavorite
        interviewCount = jobApplication.interviews.count
    }
}
