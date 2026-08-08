//
//  EditJobApplicationView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/7/26.
//

import SwiftUI

struct EditJobApplicationView: View {
    @Bindable var jobApplication: JobApplication
    
    var body: some View {
        ScreenContainer {
            VStack(spacing: 30) {
                StatusSection(currentStatus: $jobApplication.status)
                TextFieldSection(title: "ROLE · optional", placeholder: "e.g. Role ABC", text: $jobApplication.role)
                TextFieldSection(title: "COMPANY · optional", placeholder: "e.g. Company ABC", text: $jobApplication.company)
                OverallExperienceSection(overallExperience: $jobApplication.overallExperience)
                RatingSection(rating: $jobApplication.rating)
                TextFieldSection(title: "FEELING · optional", placeholder: "How did it feel, in a few words?", text: $jobApplication.feeling)
                HeaderView(text: "APPLICATION DATE")
                HeaderView(text: "INTERVIEWS · optional")
            }
        }
        .navigationTitle("Edit Application")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 8)
    }
}

#Preview {
    EditJobApplicationView(jobApplication: JobApplication())
}

