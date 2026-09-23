//
//  TestModelContainer.swift
//  SimplyJobTrackerTests
//

import SwiftData
@testable import SimplyJobTracker

@MainActor
func previewContainer() throws -> ModelContainer {
    try ModelContainer(
        for: JobApplication.self, Interview.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
}
