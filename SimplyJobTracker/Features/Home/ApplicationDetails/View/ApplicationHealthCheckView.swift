//
//  ApplicationHealthCheckView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import SwiftUI

@available(iOS 26.0, *)
struct ApplicationHealthCheckView: View {
    @State var viewModel: ApplicationHealthCheckViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScreenContainer(color: .cardBackground) {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView()
                case .loaded(let assessment):
                    AssessmentView(assessment: assessment)
                case .failed:
                    ErrorView {
                        Task { await viewModel.runAssessment() }
                    }
                }
            }
            .padding([.top, .leading, .trailing])
            .navigationTitle("AI Health Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.5)])
        .presentationBackground(.cardBackground)
        .task {
            if case .idle = viewModel.state {
                await viewModel.runAssessment()
            }
        }
    }
}
