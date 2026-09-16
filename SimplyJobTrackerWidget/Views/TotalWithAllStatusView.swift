//
//  TotalWithAllStatusView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import SwiftUI

struct TotalWithAllStatusView: View {
    let entry: JobApplicationEntry
    
    var body: some View {
        VStack(spacing: 16) {
            TotalWithPositiveStatusView(entry: entry)
            Divider()
            HStack {
                StatusView(total: entry.numberOfRejected, title: "Rejected", color: .secondary)
                Spacer()
                StatusView(total: entry.numberOfGhosted, title: "Ghosted", color: .secondary)
            }
        }
    }
}
