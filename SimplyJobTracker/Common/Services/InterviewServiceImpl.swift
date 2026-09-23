//
//  InterviewServiceImpl.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/11/26.
//

import SwiftData
import SwiftUI

enum InterviewMoveDirection {
    case up, down
}

protocol InterviewService: AnyObject {
    func addInterview(to jobApplication: JobApplication) throws
    func deleteInterview(_ interview: Interview) throws
    func moveInterview(_ interview: Interview, in jobApplication: JobApplication, direction: InterviewMoveDirection) throws
}

final class InterviewServiceImpl: InterviewService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addInterview(to jobApplication: JobApplication) throws {
        let interview = Interview()
        interview.sortOrder = jobApplication.interviews.count
        modelContext.insert(interview)
        jobApplication.interviews.append(interview)

        try modelContext.save()
    }

    func deleteInterview(_ interview: Interview) throws {
        modelContext.delete(interview)

        try modelContext.save()
    }

    func moveInterview(_ interview: Interview, in jobApplication: JobApplication, direction: InterviewMoveDirection) throws {
        let ordered = jobApplication.interviews.sorted { $0.sortOrder < $1.sortOrder }
        guard let currentIndex = ordered.firstIndex(where: { $0.persistentModelID == interview.persistentModelID }) else {
            return
        }

        let swapIndex = direction == .up ? currentIndex - 1 : currentIndex + 1
        guard ordered.indices.contains(swapIndex) else {
            return
        }

        let current = ordered[currentIndex]
        let swapped = ordered[swapIndex]
        let currentSortOrder = current.sortOrder
        current.sortOrder = swapped.sortOrder
        swapped.sortOrder = currentSortOrder

        try modelContext.save()
    }
}
