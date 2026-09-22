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
        
        let fragment = JobApplicationDialogText.roleCompanyFragment(role: latestEntity.role, company: latestEntity.company)
        let fragmentClause = fragment.map { " \($0)" } ?? ""

        try await requestConfirmation(
            dialog: "Your latest application\(fragmentClause). Want the full summary?"
        )
        
        return .result(dialog: "\(latestEntity.summaryDialog)")
    }
}
