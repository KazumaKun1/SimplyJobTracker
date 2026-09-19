//
//  ApplicationDetailsView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/9/26.
//

import SwiftUI

struct ApplicationDetailsView: View {
    var jobApplication: JobApplication
    var viewModel: EditJobApplicationViewModel
    
    var body: some View {
        ScreenContainer {
            JobDetailsView(application: jobApplication)
        }
        .navigationTitle("View Application")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showEditJobApplication(for: jobApplication)
                } label: {
                    Text("Edit")
                        .foregroundStyle(.blue)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: jobApplication.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(jobApplication.isFavorite ? Color.yellow : .primary)
                    .font(.caption)
                    .onTapGesture {
                        jobApplication.isFavorite.toggle()
                    }
                    .accessibilityLabel("Favorite")
                    .accessibilityValue(jobApplication.isFavorite ? "On" : "Off")
                    .accessibilityAddTraits(.isToggle)
                    .accessibilityRemoveTraits(.isButton)
            }
        }
    }
}
