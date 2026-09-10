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
    
    var body: some View {
        ScreenContainer {
            VStack(spacing: 16) {
                BackupView()
                DataPrivacyView()
                TippingJar(packages: viewModel.packages) { package in
                    Task {
                        await viewModel.purchase(package)
                    }
                }
                DataSection()

                Text("\(applications.count) entries found")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadPackages()
        }
    }
}

#Preview {
    SettingsView(viewModel: .init(service: TipJarServiceImpl(), coordinator: .init()))
}
