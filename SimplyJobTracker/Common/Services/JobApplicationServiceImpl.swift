//
//  JobApplicationService.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import SwiftData

protocol JobApplicationService: Actor {
    func createJobApplication() throws
    func createInterview(from id: PersistentIdentifier) throws
    func delete(id: PersistentIdentifier) throws
}

nonisolated enum JobApplicationServiceError: Error {
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
    
    func createInterview(from id: PersistentIdentifier) throws {
        guard let jobApplication = modelContext.model(for: id) as? JobApplication else {
            throw JobApplicationServiceError.notFound
        }
        
        let interview = Interview()
        jobApplication.interviews.append(interview)
        
        try modelContext.save()
    }
    
    func delete(id: PersistentIdentifier) throws {
        guard let jobApplication = modelContext.model(for: id) as? JobApplication else {
            throw JobApplicationServiceError.notFound
        }
        
        modelContext.delete(jobApplication)
        try modelContext.save()
    }
}
