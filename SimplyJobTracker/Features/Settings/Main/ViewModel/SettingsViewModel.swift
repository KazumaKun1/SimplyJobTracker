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
    
    private let service: TipJarService
    
    var packages: [Package] = []
    
    init(service: TipJarService, coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        self.service = service
    }
}

// MARK: - Service
extension SettingsViewModel {
    func loadPackages() async {
        do {
            packages = try await service.fetchPackages()
        } catch {
            packages = []
        }
    }
    
    func purchase(_ package: Package) async -> Bool {
        do {
            return try await service.purchase(package)
        } catch {
            coordinator?
                .presentAlert(
                    .init(
                        title: "Tip Didn't Go Through",
                        message: "Something went wrong on our end. You haven't been charged — feel free to try again!",
                        primaryButton: .init(title: "I understand")
                    )
                )
            return false
        }
    }
}
