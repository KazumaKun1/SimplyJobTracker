//
//  JobApplicationDeletionService.swift
//  SimplyJobTracker
//

import SwiftData
import WidgetKit

protocol JobApplicationDeletionService: AnyObject {
    func deleteJobApplication(_ jobApplication: JobApplication) throws
}

final class JobApplicationDeletionServiceImpl: JobApplicationDeletionService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func deleteJobApplication(_ jobApplication: JobApplication) throws {
        modelContext.delete(jobApplication)
        try modelContext.save()

        WidgetCenter.shared.reloadAllTimelines()
    }
}
