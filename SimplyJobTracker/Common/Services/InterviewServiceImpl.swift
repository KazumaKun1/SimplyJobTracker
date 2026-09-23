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
        interview.sortOrder = (jobApplication.interviews.map(\.sortOrder).max() ?? -1) + 1
        modelContext.insert(interview)
        jobApplication.interviews.append(interview)

        try modelContext.save()
    }

    func deleteInterview(_ interview: Interview) throws {
        modelContext.delete(interview)

        try modelContext.save()
    }

    func moveInterview(_ interview: Interview, in jobApplication: JobApplication, direction: InterviewMoveDirection) throws {
        let ordered = jobApplication.interviews.sorted(by: Interview.orderedComparator)

        for (index, interview) in ordered.enumerated() {
            interview.sortOrder = index
        }

        guard let currentIndex = ordered.firstIndex(where: { $0.persistentModelID == interview.persistentModelID }) else {
            return
        }

        let swapIndex = direction == .up ? currentIndex - 1 : currentIndex + 1
        guard ordered.indices.contains(swapIndex) else {
            return
        }

        ordered[currentIndex].sortOrder = swapIndex
        ordered[swapIndex].sortOrder = currentIndex

        try modelContext.save()
    }
}
