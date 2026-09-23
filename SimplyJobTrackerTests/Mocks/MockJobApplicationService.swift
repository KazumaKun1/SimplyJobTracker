//
//  MockJobApplicationService.swift
//  SimplyJobTrackerTests
//

import Foundation
import SwiftData
@testable import SimplyJobTracker

actor MockJobApplicationService: JobApplicationService {
    var createJobApplicationCalled = false
    var createJobApplicationWithInputCalled: NewJobApplicationInput?
    var deleteJobApplicationCalledWith: PersistentIdentifier?
    var deleteAllJobApplicationsCalled = false

    private var createError: Error?
    private var deleteError: Error?
    private var deleteAllError: Error?
    private var countResult = 0
    private var latestApplicationResult: JobApplicationEntity?
    private var exportURL: URL?
    private var exportError: Error?

    func setCreateError(_ error: Error?) { createError = error }
    func setDeleteError(_ error: Error?) { deleteError = error }
    func setDeleteAllError(_ error: Error?) { deleteAllError = error }
    func setCountResult(_ value: Int) { countResult = value }
    func setLatestApplicationResult(_ value: JobApplicationEntity?) { latestApplicationResult = value }
    func setExportURL(_ url: URL?) { exportURL = url }
    func setExportError(_ error: Error?) { exportError = error }

    func createJobApplication() throws {
        createJobApplicationCalled = true
        if let createError { throw createError }
    }

    func createJobApplication(_ input: NewJobApplicationInput) throws {
        createJobApplicationWithInputCalled = input
        if let createError { throw createError }
    }

    func deleteJobApplication(id: PersistentIdentifier) throws {
        deleteJobApplicationCalledWith = id
        if let deleteError { throw deleteError }
    }

    func deleteAllJobApplications() throws {
        deleteAllJobApplicationsCalled = true
        if let deleteAllError { throw deleteAllError }
    }

    func countApplications(status: JobApplicationStatus?) throws -> Int {
        countResult
    }

    func getLatestApplication() throws -> JobApplicationEntity? {
        latestApplicationResult
    }

    func exportCSVFile() throws -> URL {
        if let exportError { throw exportError }
        guard let exportURL else { throw JobApplicationServiceError.emptyRecords }
        return exportURL
    }
}
