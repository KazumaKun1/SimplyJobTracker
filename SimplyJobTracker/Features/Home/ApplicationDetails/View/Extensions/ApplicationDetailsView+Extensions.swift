//
//  ApplicationDetailsView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/9/26.
//

import SwiftUI

extension ApplicationDetailsView {
    struct JobDetailsView: View {
        let application: JobApplication
        
        var body: some View {
            VStack(alignment: .leading) {
                JobHeaderView(
                    title: application.status.title,
                    textColor: application.status.color,
                    role: application.role,
                    company: application.company,
                    date: application.date
                )
                
                Divider()
                    .padding(.vertical)
                
                JobMetricsView(interviewCount: application.interviews.count, rating: application.rating)
                if application.interviews.count > 0 {
                    InterviewFlowView(interviews: application.interviews)
                }

                DetailView(headerTitle: "NOTES", text: application.overallExperience.nilIfEmpty)
                    .padding(.bottom, 6)
                DetailView(headerTitle: "HOW IT FELT", text: application.feeling.nilIfEmpty)
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Job Header View
extension ApplicationDetailsView {
    struct JobHeaderView: View {
        let title: String
        let textColor: Color
        let role: String?
        let company: String?
        let date: Date
        
        var body: some View {
            Group {
                JobApplicationStatusView(title: title, color: textColor)
                Text(role ?? "Untitled Role")
                    .font(.largeTitle)
                Text(company ?? "Untitled Company")
                    .font(.title3)
                    .padding(.bottom, 8)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Text("Applied")
                    Text(date, style: .date)
                }
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
            }
        }
    }
}

// MARK: - Job Metrics View
extension ApplicationDetailsView {
    struct JobMetricsView: View {
        let interviewCount: Int
        let rating: Int?
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(interviewCount)")
                        .font(.title)
                    Text("Interview")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 6)
                )
                
                VStack(alignment: .leading) {
                    Group {
                        if let rating {
                            Text("\(rating)/5")
                        } else {
                            Text("-")
                        }
                    }
                    .font(.title)
                    Text("Rating")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 6)
                )
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Interview Flow
extension ApplicationDetailsView {
    struct InterviewFlowView: View {
        let interviews: [Interview]
        
        var body: some View {
            VStack {
                HeaderView(text: "INTERVIEW ROUNDS", textColor: .gray.opacity(0.6))
                    .padding(.bottom, 8)
                VStack(spacing: 0) {
                    ForEach(Array(interviews.enumerated()), id: \.offset) { index, interview in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 4) {
                                Image(systemName: "circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                                if index != interviews.count - 1 {
                                    VLine()
                                        .stroke(Color.gray.opacity(0.6), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                        .frame(width: 1)
                                        .frame(maxHeight: .infinity)
                                        .padding(.bottom, 2)
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text(interview.title ?? "Untitled Interview")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(interview.date, style: .date)
                                        .font(.caption)
                                }

                                Text(interview.descriptionContent.nilIfEmpty ?? "Not Added yet")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.bottom, index != interviews.count - 1 ? 12 : 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.bottom, 6)
        }
    }
}

// MARK: - Vertical Line Shape
struct VLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

// MARK: - Common
extension ApplicationDetailsView {
    struct DetailView: View {
        let headerTitle: String
        let text: String?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HeaderView(text: headerTitle, textColor: .gray.opacity(0.6))
                Text(text ?? "Not added yet")
                    .font(.subheadline)
                    .foregroundStyle(text != nil ? .primary : Color.gray.opacity(0.6))
            }
        }
    }
}
