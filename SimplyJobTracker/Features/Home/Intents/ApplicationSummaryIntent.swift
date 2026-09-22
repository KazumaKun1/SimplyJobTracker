//
//  ApplicationSummaryIntent.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/21/26.
//

import AppIntents

struct ApplicationSummaryIntent: AppIntent {
    static let title: LocalizedStringResource = "Job Application Summary"
    
    @Parameter(title: "Job Application")
    var application: JobApplicationEntity
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "\(application.summaryDialog)")
    }
}
