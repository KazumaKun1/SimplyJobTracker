//
//  JobApplicationService.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import SwiftData
import SwiftUI
import WidgetKit

protocol JobApplicationService: Actor {
    func createJobApplication() throws
    func createJobApplication(_ input: NewJobApplicationInput) throws
    func deleteJobApplication(id: PersistentIdentifier) throws
    func deleteAllJobApplications() throws
    func countApplications(status: JobApplicationStatus?) throws -> Int
    func getLatestApplication() throws -> JobApplicationEntity?
    func exportCSVFile() throws -> URL
}

enum JobApplicationServiceError: Error {
    case notFound
    case emptyRecords
}

@ModelActor
actor JobApplicationServiceImpl: JobApplicationService {
    func createJobApplication() throws {
        let jobApplication = JobApplication()
        modelContext.insert(jobApplication)
        
        try modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func createJobApplication(_ input: NewJobApplicationInput) throws {
        let jobApplication = JobApplication()
        jobApplication.company = input.company
        jobApplication.role = input.role
        jobApplication.status = input.status

        modelContext.insert(jobApplication)
        try modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }

    func deleteJobApplication(id: PersistentIdentifier) throws {
        guard let jobApplication = modelContext.model(for: id) as? JobApplication else {
            throw JobApplicationServiceError.notFound
        }

        modelContext.delete(jobApplication)
        try modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func deleteAllJobApplications() throws {
        try modelContext.delete(model: JobApplication.self)
        try modelContext.save()
        
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Siri
extension JobApplicationServiceImpl {
    func countApplications(status: JobApplicationStatus?) throws -> Int {
        // TODO: - Find a way to use `fetchCount` here for an enum comparison on predicate. Temporary fix
        let descriptor = FetchDescriptor<JobApplication>()
        let applications = try modelContext.fetch(descriptor)

        if let status {
            return applications.filter { $0.status == status }.count
        }
        
        return applications.count
    }
    
    func getLatestApplication() throws -> JobApplicationEntity? {
        var descriptor = FetchDescriptor<JobApplication>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        
        guard let application = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return JobApplicationEntity(application)
    }
}

// MARK: - CSV Export

extension JobApplicationServiceImpl {
    func exportCSVFile() throws -> URL {
        let rows = try fetchAllForExport()
        guard !rows.isEmpty else { throw JobApplicationServiceError.emptyRecords }
        return try CSVExporter.writeToTemporaryFile(rows)
    }
    
    private func fetchAllForExport() throws -> [JobApplicationExportRow] {
        modelContext.rollback()

        let descriptor = FetchDescriptor<JobApplication>(sortBy: [SortDescriptor(\.date)])
        let applications = try modelContext.fetch(descriptor)
        return applications.map(JobApplicationExportRow.init)
    }
}
