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
            VStack(spacing: 30) {
                StatusSection(currentStatus: $jobApplication.status)
                TextFieldSection(title: "Name of the Role · optional", placeholder: "e.g. Role ABC", text: $jobApplication.role)
                TextFieldSection(title: "Name of the Company · optional", placeholder: "e.g. Company ABC", text: $jobApplication.company)
                OverallExperienceSection(overallExperience: $jobApplication.overallExperience)
                RatingSection(rating: $jobApplication.rating)
                TextFieldSection(title: "How it felt · optional", placeholder: "How did it feel, in a few words?", text: $jobApplication.feeling)
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
            .padding(.horizontal)
            .padding(.bottom)
            .onChange(of: jobApplication.interviews) { _, _ in
                withAnimation {
                    proxy.scrollTo("DeleteJobApplication", anchor: .bottom)
                }
            }
        }
        .alert(
            "Confirmation",
            isPresented: Binding(
                get: { activeAlert != nil },
                set: { isPresented in
                    if !isPresented {
                        activeAlert = nil
                    }
                }
            ),
            presenting: activeAlert
        ) { alertType in
            Button("Cancel", role: .cancel) {}
            switch alertType {
            case .deleteJobApplication:
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteJobApplication(jobApplication)
                    }
                }
            case .deleteInterview(let interview):
                Button("Delete", role: .destructive) {
                    viewModel.deleteInterview(interview)
                }
            }
        } message: { alertType in
            switch alertType {
            case .deleteJobApplication:
                Text("Are you sure you want to delete this job application?")
            case .deleteInterview:
                Text("Are you sure you want to delete this interview?")
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
