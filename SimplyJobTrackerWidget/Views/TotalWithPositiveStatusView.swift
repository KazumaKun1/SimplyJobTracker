//
//  TotalWithPositiveStatusView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import SwiftUI

struct TotalWithPositiveStatusView: View {
    let entry: JobApplicationEntry
    
    var body: some View {
        HStack(spacing: 20) {
            TotalOnlyView(numberOfApplications: entry.total)
            Divider()
            VStack(spacing: 4) {
                StatusView(total: entry.numberOfApplied, title: "Applied", color: .applied)
                StatusView(total: entry.numberOfInterviewing, title: "Interviewing", color: .interviewing)
                StatusView(total: entry.numberOfOffers, title: "Offers", color: .offers)
            }
        }
    }
}
