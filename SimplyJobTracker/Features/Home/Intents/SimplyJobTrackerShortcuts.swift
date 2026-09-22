//
//  SimplyJobTrackerShortcuts.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/21/26.
//

import AppIntents

struct SimplyJobTrackerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddJobApplicationIntent(),
            phrases: [
                "Add a job application in \(.applicationName)",
                "Log a new application in \(.applicationName)"
            ],
            shortTitle: "Add Job Application",
            systemImageName: "briefcase.fill"
        )
        AppShortcut(
            intent: CountApplicationIntent(),
            phrases: [
                "How many job applications do I have in \(.applicationName)",
                "How many job applications are \(\.$status) in \(.applicationName)"
            ],
            shortTitle: "Count Job Applications",
            systemImageName: "number"
        )
        AppShortcut(
            intent: ApplicationSummaryIntent(),
            phrases: [
                "What is my job application summary in \(.applicationName)"
            ],
            shortTitle: "Job Application Summary",
            systemImageName: "text.pad.header"
        )
        AppShortcut(
            intent: LatestApplicationIntent(),
            phrases: [
                "What is my latest job application in \(.applicationName)"
            ],
            shortTitle: "Latest Job Application",
            systemImageName: "doc.fill"
        )
    }
}
