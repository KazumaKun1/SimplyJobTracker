//
//  EditJobApplicationView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/7/26.
//

import SwiftUI
import SwiftData

// MARK: - Status Selection Section
extension EditJobApplicationView {
    struct StatusSection: View {
        @Binding var currentStatus: JobApplicationStatus
        
        private let statuses = JobApplicationStatus.allCases
        
        private let columns = [
            GridItem(.flexible(),spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]
        
        var body: some View {
            CustomSection {
                HeaderView(text: "STATUS")
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(statuses, id: \.self) { status in
                        Button {
                            currentStatus = status
                        } label: {
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 15, height: 15)
                                Text(status.title)
                                    .font(.callout)
                                    .fontWeight(currentStatus == status ? .bold : .regular)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(status.color.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(status.color, lineWidth: 1)
                                    .opacity(currentStatus == status ? 1 : 0)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(status.title)
                        .accessibilityAddTraits(currentStatus == status ? [.isSelected] : [])
                        .animation(.default, value: currentStatus)
                    }
                }
            }
        }
    }
}

// MARK: - Overall Experience Section
extension EditJobApplicationView {
    struct OverallExperienceSection: View {
        @Binding var overallExperience: String?
        
        var body: some View {
            CustomSection {
                HeaderView(text: "Notes · optional")
                TextField("Notes about the process, the team, or the work environment", text: $overallExperience.unwrapped(), axis: .vertical)
                    .lineLimit(4...)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    )
            }
        }
    }
}

// MARK: - Rating Section
extension EditJobApplicationView {
    struct RatingSection: View {
        @Binding var rating: Int?
        
        private let maxRating = 5
        private let offColor = Color.secondary.opacity(0.2)
        private let onColor = Color.blue
        
        var body: some View {
            CustomSection {
                HeaderView(text: "Rating · optional")
                HStack {
                    ForEach(1...maxRating, id: \.self) { number in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                rating = number
                            }
                        } label: {
                            Image(systemName: "circle.fill")
                                .font(.title2)
                                .foregroundStyle(number <= (rating ?? 0) ? onColor : offColor)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Rating \(number) of \(maxRating)")
                        .accessibilityAddTraits(number <= (rating ?? 0) ? [.isSelected] : [])
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Application Date Section
extension EditJobApplicationView {
    struct CalendarSection: View {
        @Binding var date: Date?
        
        var body: some View {
            CustomSection {
                HeaderView(text: "Date Applied")
                DatePicker("", selection: $date.unwrapped(), in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 6)
                    )
            }
        }
    }
}

// MARK: - Interviews Section
extension EditJobApplicationView {
    struct InterviewSection: View {
        let interviews: [Interview]
        let addInterviewAction: () -> Void
        let deleteInterviewAction: (Interview) -> Void

        var body: some View {
            CustomSection {
                HeaderView(text: "Interviews · optional", leadingContent: {}) {
                    Button {
                        addInterviewAction()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                        .font(.callout)
                    }
                }
                Group {
                    if interviews.isEmpty {
                        Text("You can add an interview here by tapping on '+' button above")
                            .font(.callout)
                            .foregroundStyle(.gray.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(interviews) { interview in
                                InterviewCard(interview: interview) {
                                    deleteInterviewAction(interview)
                                }
                            }
                        }
                    }
                }
                .animation(.smooth, value: interviews)
            }
        }
    }
    
    enum CardMode {
        case display, edit
        
        mutating func toggle() {
            self = (self == .display) ? .edit : .display
        }
    }
    
    struct InterviewCard: View {
        let interview: Interview
        @State private var isExpanded: Bool = false
        @State private var mode: CardMode = .display
        
        let deleteInterviewAction: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                if mode == .display {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        InterviewContentView(interview: interview, mode: mode, isExpanded: isExpanded)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(interview.title ?? "Untitled Interview")
                    .accessibilityAddTraits(isExpanded ? [.isSelected] : [])
                    .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
                } else {
                    InterviewContentView(interview: interview, mode: mode, isExpanded: isExpanded)
                }

                if isExpanded {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                mode.toggle()
                            }
                        } label: {
                            Label(mode == .display ? "Edit" : "Done", systemImage: "pencil")
                                .foregroundStyle(.blue)
                        }
                        
                        Divider()

                        Button {
                            deleteInterviewAction()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.cardBackground)
                    .shadow(color: .black.opacity(0.1), radius: 4)
            )
        }
    }

    struct InterviewContentView: View {
        @Bindable var interview: Interview
        let mode: CardMode
        let isExpanded: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                if mode == .display {
                    HStack {
                        Text(interview.title ?? "Untitled Interview")
                            .font(.headline)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.blue)
                    }
                    if isExpanded {
                        Text(interview.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        Text(interview.descriptionContent ?? "e.g. the interviewer asked about...")
                            .multilineTextAlignment(.leading)
                    }
                } else {
                    TextFieldView(placeholder: "Untitled Interview", text: $interview.title)
                        .font(.headline)
                    if isExpanded {
                        DatePicker("Select Date", selection: $interview.date, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                        TextFieldView(placeholder: "e.g. the interview asked about...", text: $interview.descriptionContent)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding(.bottom, isExpanded ? 16 : 0)
        }
    }
}

// MARK: - Common
extension EditJobApplicationView {
    struct TextFieldSection: View {
        let title: String
        let placeholder: String
        var text: Binding<String?>
        
        var body: some View {
            CustomSection {
                HeaderView(text: title)
                TextFieldView(placeholder: placeholder, text: text)
            }
        }
    }
    
    struct TextFieldView: View {
        let placeholder: String
        @Binding var text: String?
        
        @FocusState private var isFocused: Bool
        
        var body: some View {
            VStack {
                TextField(placeholder, text: $text.unwrapped(), axis: .vertical)
                    .lineLimit(1...2)
                    .focused($isFocused)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray.opacity(isFocused ? 0.6 : 0.2))
                    .animation(.linear(duration: 0.15), value: isFocused)
            }
        }
    }
    
    struct CustomSection<Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                content
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
