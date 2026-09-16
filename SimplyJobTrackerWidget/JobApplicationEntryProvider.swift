//
//  JobApplicationEntryProvider.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import WidgetKit
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> JobApplicationEntry {
        JobApplicationEntry(
            date: .now,
            numberOfApplied: 0,
            numberOfInterviewing: 0,
            numberOfOffers: 0,
            numberOfRejected: 0,
            numberOfGhosted: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (JobApplicationEntry) -> ()) {
        if context.isPreview {
            let entry = JobApplicationEntry(
                date: .now,
                numberOfApplied: 20,
                numberOfInterviewing: 32,
                numberOfOffers: 15,
                numberOfRejected: 2,
                numberOfGhosted: 1
            )
            completion(entry)
            return
        }
        completion(fetchCurrentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchCurrentEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

private extension Provider {
    func fetchCurrentEntry() -> JobApplicationEntry {
        let container = SharedModelContainer.shared
        let context = ModelContext(container)
        
        let applications = (try? context.fetch(FetchDescriptor<JobApplication>())) ?? []
        
        func count(_ status: JobApplicationStatus) -> Int {
            applications.filter { $0.status == status }.count
        }
        
        return JobApplicationEntry(
            date: .now,
            numberOfApplied: count(.applied),
            numberOfInterviewing: count(.interviewing),
            numberOfOffers: count(.offer),
            numberOfRejected: count(.rejected),
            numberOfGhosted: count(.ghosted)
        )
    }
}
