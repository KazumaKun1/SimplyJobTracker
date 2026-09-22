//
//  ApplicationHealthCheckView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import SwiftUI

// MARK: - Loading
@available(iOS 26.0, *)
extension ApplicationHealthCheckView {
    struct LoadingView: View {
        var body: some View {
            VStack(spacing: 12) {
                ProgressView()
                Text("Assessing this application…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
            .accessibilityElement(children: .combine)
        }
    }
}

// MARK: - Assessment
@available(iOS 26.0, *)
extension ApplicationHealthCheckView {
    struct AssessmentView: View {
        let assessment: ApplicationHealthAssessment

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                JobApplicationStatusView(title: assessment.status.title, color: assessment.status.color)

                DetailSection(headerTitle: "SUMMARY", text: assessment.summary)
                DetailSection(headerTitle: "SUGGESTED NEXT ACTION", text: assessment.suggestedNextAction)

                Spacer()
                
                Text("AI-generated take. Not a verdict. Take it as a nudge, not a rule.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct DetailSection: View {
        let headerTitle: String
        let text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HeaderView(text: headerTitle, textColor: .gray.opacity(0.6))
                Text(text)
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - Error
@available(iOS 26.0, *)
extension ApplicationHealthCheckView {
    struct ErrorView: View {
        let retry: () -> Void

        var body: some View {
            VStack(spacing: 12) {
                Text("Couldn't generate a health check for this application.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Try Again", action: retry)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        }
    }
}

@available(iOS 26.0, *)
extension ApplicationHealthStatus {
    var title: String {
        switch self {
        case .thriving: "Thriving"
        case .steady: "Steady"
        case .needsAttention: "Needs Attention"
        case .stale: "Stale"
        }
    }

    var color: Color {
        switch self {
        case .thriving: .green
        case .steady: .blue
        case .needsAttention: .orange
        case .stale: .red
        }
    }
}
