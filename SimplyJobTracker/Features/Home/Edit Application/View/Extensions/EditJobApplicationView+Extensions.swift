//
//  EditJobApplicationView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/7/26.
//

import SwiftUI

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
                        .onTapGesture {
                            currentStatus = status
                        }
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
                HeaderView(text: "OVERALL EXPERIENCE · optional")
                TextField("Notes about the process", text: $overallExperience.unwrapped(), axis: .vertical)
                    .lineLimit(4...)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.cardBackground)
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
        private let offColor = Color.white.opacity(0.2)
        private let onColor = Color.blue
        
        var body: some View {
            CustomSection {
                HeaderView(text: "RATING · optional")
                HStack {
                    ForEach(1...maxRating, id: \.self) { number in
                        Image(systemName: "circle.fill")
                            .font(.title2)
                            .foregroundStyle(number <= (rating ?? 0) ? onColor : offColor)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    rating = number
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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
            VStack(spacing: 15) {
                content
            }
        }
    }
}

#Preview {
    EditJobApplicationView(jobApplication: JobApplication())
}
