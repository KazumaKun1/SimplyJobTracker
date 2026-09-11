//
//  SettingsView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/10/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    var viewModel: SettingsViewModel
    
    @Query private var applications: [JobApplication]
    
    @State private var showEraseDataConfirmation = false
    
    var body: some View {
        ScreenContainer {
            VStack(spacing: 16) {
                BackupView()
                DataPrivacyView()
                TippingJar(shouldShowThankYou: viewModel.showThankYouMessage, packages: viewModel.packages) { package in
                    Task {
                        await viewModel.purchase(package)
                    }
                }
                DataSection {
                    
                } deleteDataAction: {
                    showEraseDataConfirmation = true
                }

                Text("\(applications.count) entries found")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding()
            .animation(.easeInOut(duration: 0.5), value: viewModel.showThankYouMessage)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadPackages()
        }
        .alert("Confirmation", isPresented: $showEraseDataConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.eraseData()
                }
            }
        } message: {
            Text("Are you sure you want to erase all job applications?")
        }
    }
}
