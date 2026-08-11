//
//  InterviewServiceImpl.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/11/26.
//

import SwiftData
import SwiftUI

protocol InterviewService: AnyObject {
    func addInterview(to jobApplication: JobApplication) throws
    func deleteInterview(_ interview: Interview) throws
}

final class InterviewServiceImpl: InterviewService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addInterview(to jobApplication: JobApplication) throws {
        let interview = Interview()
        modelContext.insert(interview)
        jobApplication.interviews.append(interview)
        
        // TODO: - Find a way to not enclose this to task as this will swallow error. But this is the only way to fix the animation hitches when doing modification while animating.
        Task { @MainActor in
            try? modelContext.save()
        }
    }

    func deleteInterview(_ interview: Interview) throws {
        modelContext.delete(interview)
        Task { @MainActor in
            try? modelContext.save()
        }
    }
}
