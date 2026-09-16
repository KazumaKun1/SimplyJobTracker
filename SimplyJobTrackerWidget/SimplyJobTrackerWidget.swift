//
//  SimplyJobTrackerWidget.swift
//  SimplyJobTrackerWidget
//
//  Created by Arviejhay Alejandro on 9/15/26.
//

import SwiftUI
import WidgetKit

struct SimplyJobTrackerWidget: Widget {
    let kind: String = "SimplyJobTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimplyJobTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Job Applications")
        .description("See your applied, interviewing, offer, rejected, and ghosted counts at a glance.")
    }
}

#Preview(as: .systemSmall) {
    SimplyJobTrackerWidget()
} timeline: {
    JobApplicationEntry(
        date: Date(),
        numberOfApplied: 10,
        numberOfInterviewing: 14,
        numberOfOffers: 3,
        numberOfRejected: 37,
        numberOfGhosted: 40
    )
}
