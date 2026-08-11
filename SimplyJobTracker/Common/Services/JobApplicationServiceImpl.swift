//
//  JobApplicationService.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import SwiftData
import SwiftUI

protocol JobApplicationService: AnyObject {
    func createJobApplication() throws
    func deleteJobApplication(id: PersistentIdentifier) throws
}

enum JobApplicationServiceError: Error {
    case notFound
    case deletionFailed
}

final class JobApplicationServiceImpl: JobApplicationService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createJobApplication() throws {
        let jobApplication = JobApplication()
        modelContext.insert(jobApplication)
        
        // TODO: - Find a way to not enclose this to task as this will swallow error. But this is the only way to fix the animation hitches when doing modification while animating.
        Task { @MainActor in
            try? modelContext.save()
        }
    }

    func deleteJobApplication(id: PersistentIdentifier) throws {
        guard let jobApplication = modelContext.model(for: id) as? JobApplication else {
            throw JobApplicationServiceError.notFound
        }

        modelContext.delete(jobApplication)
        Task { @MainActor in
            try? modelContext.save()
        }
    }
}
