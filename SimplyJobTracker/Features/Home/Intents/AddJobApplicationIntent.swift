//
//  AddJobApplicationIntent.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/21/26.
//

import AppIntents

struct AddJobApplicationIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Job Application"
    static let description = IntentDescription("Add a new job application to SimplyJobTracker")
    
    @Parameter(title: "Name of the role?")
    var role: String

    @Parameter(title: "Name of the Company?")
    var company: String

    @Parameter(title: "Status")
    var status: JobApplicationStatus

    static var parameterSummary: some ParameterSummary {
        Summary("Add a job application for \(\.$role) at \(\.$company) with status \(\.$status)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = await JobApplicationServiceImpl(modelContainer: SharedModelContainer.shared)
        try await service.createJobApplication(
            .init(role: role, company: company, status: status)
        )
        
        let fragment = JobApplicationDialogText.roleCompanyFragment(role: role, company: company)
        let fragmentClause = fragment.map { " \($0)" } ?? ""

        return .result(dialog: "Added your job application\(fragmentClause) with status \(status.title)")
    }
}
