//
//  JobApplicationService.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import SwiftData
import SwiftUI

protocol JobApplicationService: Actor {
    func createJobApplication() throws
    func deleteJobApplication(id: PersistentIdentifier) throws
    func deleteAllJobApplications() throws
}

enum JobApplicationServiceError: Error {
    case notFound
    case deletionFailed
}

@ModelActor
actor JobApplicationServiceImpl: JobApplicationService {
    func createJobApplication() throws {
        let jobApplication = JobApplication()
        modelContext.insert(jobApplication)
        
        try modelContext.save()
    }

    func deleteJobApplication(id: PersistentIdentifier) throws {
        guard let jobApplication = modelContext.model(for: id) as? JobApplication else {
            throw JobApplicationServiceError.notFound
        }

        modelContext.delete(jobApplication)
        try modelContext.save()
    }
    
    func deleteAllJobApplications() throws {
        try modelContext.delete(model: JobApplication.self)
        try modelContext.save()
    }
}
