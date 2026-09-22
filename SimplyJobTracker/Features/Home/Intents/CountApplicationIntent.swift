//
//  CountApplicationIntent.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/21/26.
//

import AppIntents

struct CountApplicationIntent: AppIntent {
    static let title: LocalizedStringResource = "Count Job Applications"
    
    @Parameter(title: "Status to Filter By")
    var status: JobApplicationStatus?

    func perform() async throws -> some IntentResult & ReturnsValue<Int> & ProvidesDialog {
        let service = await JobApplicationServiceImpl(modelContainer: SharedModelContainer.shared)
        let count = try await service.countApplications(status: status)

        var dialogTitle: IntentDialog = "You have \(count) applications"
        if let status {
            dialogTitle = "You have \(count) applications with status \(status.title)"
        }
        
        return .result(value: count, dialog: dialogTitle)
    }
}
