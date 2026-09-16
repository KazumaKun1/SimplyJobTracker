//
//  WidgetEntryView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import SwiftUI
import WidgetKit

struct SimplyJobTrackerWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if entry.total == 0 {
                EmptyStateView()
            } else {
                switch family {
                case .systemSmall:
                    TotalOnlyView(numberOfApplications: entry.total)
                case .systemMedium:
                    TotalWithPositiveStatusView(entry: entry)
                case .systemLarge:
                    TotalWithAllStatusView(entry: entry)
                default:
                    TotalOnlyView(numberOfApplications: entry.total)
                }
            }
        }
        .containerBackground(.appBackground, for: .widget)
    }
}
