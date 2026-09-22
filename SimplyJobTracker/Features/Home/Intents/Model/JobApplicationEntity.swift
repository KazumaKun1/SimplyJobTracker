//
//  JobApplicationEntity.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/21/26.
//

import AppIntents
import SwiftData

struct JobApplicationEntity: AppEntity {
    let id: UUID
    let role: String
    let company: String
    let status: JobApplicationStatus
    let dateApplied: Date
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Job Application"
    
    var displayRepresentation: DisplayRepresentation {
        let roleText = role.isEmpty ? "Untitled Role" : role
        let companyText = company.isEmpty ? "Untitled Company" : company
        
        return DisplayRepresentation(
            title: "\(roleText) at \(companyText)",
            subtitle: "\(status.title) · Applied \(dateApplied.formatted(date: .abbreviated, time: .omitted))"
        )
    }
    
    static let defaultQuery = JobApplicationEntityQuery()
}

extension JobApplicationEntity {
    init(_ model: JobApplication) {
        self.init(
            id: model.id,
            role: model.role ?? "",
            company: model.company ?? "",
            status: model.status,
            dateApplied: model.date
        )
    }
}

extension JobApplicationEntity {
    var summaryDialog: String {
        let fragment = JobApplicationDialogText.roleCompanyFragment(role: role, company: company)
        let fragmentClause = fragment.map { " \($0)" } ?? ""
        return "Your job application\(fragmentClause) has a status of \(status.title), applied on \(dateApplied.formatted(date: .abbreviated, time: .omitted))."
    }
}

struct JobApplicationEntityQuery: EntityQuery {
    private func getContext() async -> ModelContext {
        let container = await SharedModelContainer.shared
        return ModelContext(container)
    }
    
    func entities(for identifiers: [UUID]) async throws -> [JobApplicationEntity] {
        let descriptor = FetchDescriptor<JobApplication>(
            predicate: #Predicate { identifiers.contains($0.id) }
        )
        
        let applications = try await getContext().fetch(descriptor)
        return applications.map { JobApplicationEntity($0) }
    }
    
    func suggestedEntities() async throws -> [JobApplicationEntity] {
        var descriptor = FetchDescriptor<JobApplication>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        
        let applications = try await getContext().fetch(descriptor)
        return applications.map { JobApplicationEntity($0) }
    }
}
