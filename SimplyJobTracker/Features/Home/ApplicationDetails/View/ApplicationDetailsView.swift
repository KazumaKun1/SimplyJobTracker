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
    
    @State private var isEditMode: Bool = false
    
    var body: some View {
        ScreenContainer {
            if isEditMode {
                EditJobApplicationView(jobApplication: jobApplication, viewModel: viewModel)
            } else {
                JobDetailsView(application: jobApplication)
            }
        }
        .navigationTitle(isEditMode ? "Edit Application" : "View Application")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isEditMode.toggle()
                } label: {
                    Text(isEditMode ? "View" : "Edit")
                        .foregroundStyle(.blue)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    jobApplication.isFavorite.toggle()
                } label: {
                    Image(systemName: jobApplication.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(jobApplication.isFavorite ? Color.yellow : .primary)
                        .font(.caption)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isEditMode)
    }
}
