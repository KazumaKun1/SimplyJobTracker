//
//  SettingsViewModel.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/10/26.
//

import SwiftUI
import RevenueCat

enum ExportState: Equatable {
    case idle
    case generating
    case ready(CSVExportItem)
}

@Observable
class SettingsViewModel {
    weak private var coordinator: SettingsCoordinator?
    
    private let jobApplicationService: JobApplicationService
    private let tipService: TipJarService
    
    var showThankYouMessage: Bool = false
    private var thankYouTask: Task<Void, Never>?
    
    var packages: [Package] = []
    
    var exportState: ExportState = .idle
    private(set) var isErasing: Bool = false
    
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

// MARK: - Export CSV
extension SettingsViewModel {
    func resetExportStateIfNeeded() {
        guard exportState != .generating else { return }

        if case .ready(let item) = exportState {
            try? FileManager.default.removeItem(at: item.fileURL)
        }
        exportState = .idle
    }

    func generateCSVFile() async {
         guard !isErasing, exportState == .idle else { return }

         withAnimation(.easeInOut(duration: 0.25)) {
             exportState = .generating
         }
         do {
             async let minimumDelay: Void = Task.sleep(for: .seconds(1))
             let url = try await jobApplicationService.exportCSVFile()
             _ = try? await minimumDelay

             withAnimation(.easeInOut(duration: 0.25)) {
                 exportState = .ready(CSVExportItem(fileURL: url))
             }
         } catch JobApplicationServiceError.emptyRecords {
             withAnimation(.easeInOut(duration: 0.25)) {
                 exportState = .idle
             }
             coordinator?
                 .presentAlert(
                     .init(
                         title: "Nothing to Export",
                         message: "Add a job application before exporting your data.",
                         primaryButton: .init(title: "Ok!")
                     )
                 )
         } catch {
             withAnimation(.easeInOut(duration: 0.25)) {
                 exportState = .idle
             }
             coordinator?
                 .presentAlert(
                     .init(
                         title: "Export Failed",
                         message: "Something went wrong while creating your CSV file. Please try again.",
                         primaryButton: .init(title: "I understand")
                     )
                 )
         }
     }
}

// MARK: - Erase Data
extension SettingsViewModel {
    func eraseData() async {
        guard exportState != .generating else { return }

        isErasing = true
        defer { isErasing = false }

        do {
            try await jobApplicationService.deleteAllJobApplications()

            if case .ready(let item) = exportState {
                try? FileManager.default.removeItem(at: item.fileURL)
            }
            withAnimation(.easeInOut(duration: 0.25)) {
                exportState = .idle
            }
        } catch {
            coordinator?
                .presentAlert(
                    .init(
                        title: "Erase Failed",
                        message: "Something went wrong while deleting your data. Please try again.",
                        primaryButton: .init(title: "I understand")
                    )
                )
        }
    }
}
