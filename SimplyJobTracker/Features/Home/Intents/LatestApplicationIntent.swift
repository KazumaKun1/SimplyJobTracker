//
//  LatestApplicationIntent.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/21/26.
//

import AppIntents

struct LatestApplicationIntent: AppIntent {
    static let title: LocalizedStringResource = "Latest Job Application"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = await JobApplicationServiceImpl(modelContainer: SharedModelContainer.shared)
        guard let latestEntity = try await service.getLatestApplication() else {
            return .result(dialog: "You don't have any job applications right now.")
        }
        
        try await requestConfirmation(
            dialog: "Your latest application is \(latestEntity.role) at \(latestEntity.company). Want the full summary?"
        )
        
        return .result(dialog: "\(latestEntity.summaryDialog)")
    }
}
