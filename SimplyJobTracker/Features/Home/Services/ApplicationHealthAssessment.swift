//
//  ApplicationHealthAssessment.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable
struct ApplicationHealthAssessment: Equatable {
    @Guide(description: "Overall health category for this application")
    var status: ApplicationHealthStatus
    @Guide(description: "One sentence, at most 20 words, summarizing the application's current state")
    var summary: String
    @Guide(description: "One concrete, specific next action the applicant should take, at most 15 words")
    var suggestedNextAction: String
}
