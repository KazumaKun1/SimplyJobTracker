//
//  JobApplicationList.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/8/26.
//

import SwiftUI

struct JobApplicationList: View {
    let jobApplications: [JobApplication]
    let actionTapped: (JobApplication) -> Void
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 10) {
            ForEach(jobApplications) { application in
                Button {
                    actionTapped(application)
                } label: {
                    JobApplicationCard(application: application)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(application.role ?? "Untitled Role") at \(application.company ?? "Untitled Company"), \(application.status.title)")
            }
        }
        .padding(.bottom)
        .animation(.easeInOut(duration: 0.25), value: jobApplications.count)
        Spacer()
    }
}

struct JobApplicationCard: View {
    let application: JobApplication

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(application.status.title)
                    .foregroundStyle(application.status.color)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(application.status.color)
                            .opacity(0.2)
                    )
                Text(application.role ?? "Untitled Role")
                    .font(.headline)
                HStack {
                    Text(application.company ?? "Untitled Company")
                        .font(.subheadline)
                    if !application.interviews.isEmpty {
                        Text(" • ")
                        Text(application.interviews.fullDescription)
                    }
                }
            }
            Spacer()
            Text(application.date, format: .dateTime.month(.abbreviated).day())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .foregroundStyle(.cardBackground)
                .shadow(color: .black.opacity(0.1),  radius: 6)
        )
    }
}
