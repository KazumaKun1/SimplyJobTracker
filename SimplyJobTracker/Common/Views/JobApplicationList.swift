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
                let applicationDate = application.date.formatted(.dateTime.month(.wide).day().year())
                let valueKey: LocalizedStringKey = application.interviews.count > 0
                    ? "^[\(application.interviews.count) interview](inflect: true), Application Date is \(applicationDate)"
                    : "Application Date is \(applicationDate)"
                Button {
                    actionTapped(application)
                } label: {
                    JobApplicationCard(application: application)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(application.role.nilIfEmpty ?? "Untitled Role") at \(application.company.nilIfEmpty ?? "Untitled Company"), \(application.status.title)\(application.isFavorite ? ", Favorite" : "")")
                .accessibilityValue(valueKey)
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
                JobApplicationStatusView(title: application.status.title, color: application.status.color)
                Text(application.role.nilIfEmpty ?? "Untitled Role")
                    .font(.headline)
                HStack {
                    Text(application.company.nilIfEmpty ?? "Untitled Company")
                        .font(.subheadline)
                    if !application.interviews.isEmpty {
                        Text(" • ")
                        Text("^[\(application.interviews.count) interview](inflect: true)")
                    }
                }
            }
            Spacer()
            if application.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            }
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

struct JobApplicationStatusView: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .foregroundStyle(color)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(color)
                    .opacity(0.2)
            )
    }
}

#Preview {
    JobApplicationCard(application: JobApplication(isFavorite: true))
}
