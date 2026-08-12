//
//  EditJobApplicationView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/7/26.
//

import SwiftUI
import SwiftData

struct EditJobApplicationView: View {
    enum AlertType: Identifiable {
        case deleteJobApplication
        case deleteInterview(Interview)
        
        var id: String {
            switch self {
            case .deleteJobApplication: "delete-JA"
            case .deleteInterview(let interview): "delete-I-\(interview.id)"
            }
        }
    }
    
    @Bindable var jobApplication: JobApplication

    var viewModel: EditJobApplicationViewModel

    @State private var activeAlert: AlertType?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScreenContainer {
                VStack(spacing: 30) {
                    StatusSection(currentStatus: $jobApplication.status)
                    TextFieldSection(title: "ROLE · optional", placeholder: "e.g. Role ABC", text: $jobApplication.role)
                    TextFieldSection(title: "COMPANY · optional", placeholder: "e.g. Company ABC", text: $jobApplication.company)
                    OverallExperienceSection(overallExperience: $jobApplication.overallExperience)
                    RatingSection(rating: $jobApplication.rating)
                    TextFieldSection(title: "FEELING · optional", placeholder: "How did it feel, in a few words?", text: $jobApplication.feeling)
                    CalendarSection(date: $jobApplication.date.toOptional(fallback: .now))
                    InterviewSection(interviews: jobApplication.interviews) {
                        viewModel.addInterview(to: jobApplication)
                    } deleteInterviewAction: { interview in
                        activeAlert = .deleteInterview(interview)
                    }
                    
                    Button(role: .destructive) {
                        activeAlert = .deleteJobApplication
                    } label: {
                        Label("Delete Job Application", systemImage: "trash.fill")
                    }
                    .padding()
                    .id("DeleteJobApplication")
                }
            }
            .onChange(of: jobApplication.interviews) { _, _ in
                withAnimation {
                    proxy.scrollTo("DeleteJobApplication", anchor: .bottom)
                }
            }
        }
        .navigationTitle("Edit Application")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 8)
        .padding(.bottom)
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .deleteJobApplication:
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to delete this job application?"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteJobApplication(jobApplication)
                    }
                )
            case .deleteInterview(let interview):
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Are you sure you want to delete this interview?"),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteInterview(interview)
                    }
                )
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: JobApplication.self, Interview.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let coordinator = HomeCoordinator(modelContainer: container)
    EditJobApplicationView(jobApplication: JobApplication(), viewModel: coordinator.editJobApplicationViewModel)
        .modelContainer(container)
}
