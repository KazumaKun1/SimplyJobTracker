//
//  SettingsViewModel.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/10/26.
//

import SwiftUI
import RevenueCat

@Observable
class SettingsViewModel {
    weak private var coordinator: SettingsCoordinator?
    
    private let jobApplicationService: JobApplicationService
    private let tipService: TipJarService
    
    var showThankYouMessage: Bool = false
    private var thankYouTask: Task<Void, Never>?
    
    var packages: [Package] = []
    
    init(jobApplicationService: JobApplicationService, tipService: TipJarService, coordinator: SettingsCoordinator) {
        self.jobApplicationService = jobApplicationService
        self.tipService = tipService
        self.coordinator = coordinator
    }
}

// MARK: - Service
extension SettingsViewModel {
    func loadPackages() async {
        do {
            packages = try await tipService.fetchPackages()
        } catch {
            packages = []
        }
    }
    
    func purchase(_ package: Package) async {
        do {
            let isSuccessful = try await tipService.purchase(package)
            if isSuccessful {
                showThankYouMessageTemporarily()
            }
        } catch {
            coordinator?
                .presentAlert(
                    .init(
                        title: "Tip Didn't Go Through",
                        message: "Something went wrong on our end. You haven't been charged — feel free to try again!",
                        primaryButton: .init(title: "I understand")
                    )
                )
        }
    }
    
    private func showThankYouMessageTemporarily() {
        thankYouTask?.cancel()
        showThankYouMessage = true
        
        thankYouTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            showThankYouMessage = false
        }
    }
}

// MARK: - Erase Data
extension SettingsViewModel {
    func eraseData() async {
        do {
            try await jobApplicationService.deleteAllJobApplications()
        } catch {
            coordinator?
                .presentAlert(
                    .init(
                        title: "Tip Didn't Go Through",
                        message: "Something went wrong on our end. You haven't been charged — feel free to try again!",
                        primaryButton: .init(title: "I understand")
                    )
                )
        }
    }
}
