//
//  SettingsViewModelTests.swift
//  SimplyJobTrackerTests
//

import Foundation
import RevenueCat
import Testing
@testable import SimplyJobTracker

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    private func makePackage(identifier: String = "monthly") -> Package {
        let product = TestStoreProduct(
            localizedTitle: "Tip",
            price: 2.99,
            currencyCode: "USD",
            localizedPriceString: "$2.99",
            productIdentifier: "com.simplyjobtracker.tip",
            productType: .consumable,
            localizedDescription: "Tip",
            subscriptionGroupIdentifier: nil,
            subscriptionPeriod: nil,
            isFamilyShareable: false,
            introductoryDiscount: nil,
            discounts: [],
            locale: .current
        )
        return Package(
            identifier: identifier,
            packageType: .custom,
            storeProduct: product.toStoreProduct(),
            offeringIdentifier: "default",
            webCheckoutUrl: nil
        )
    }

    @Test("available tip packages load and show up in the list")
    func loadPackagesSuccess() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        tipService.fetchPackagesResult = [makePackage()]
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.loadPackages()

        #expect(viewModel.packages.count == 1)
    }

    @Test("a failed package load leaves no stale packages behind")
    func loadPackagesFailure() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        tipService.fetchPackagesError = TipJarError.offeringNotFound
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)
        viewModel.packages = [makePackage()]

        await viewModel.loadPackages()

        #expect(viewModel.packages.isEmpty)
    }

    @Test("exporting walks through generating to a ready file the user can share")
    func generateCSVHappyPath() async throws {
        let jobApplicationService = MockJobApplicationService()
        await jobApplicationService.setExportURL(FileManager.default.temporaryDirectory.appendingPathComponent("export.csv"))
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.generateCSVFile()

        guard case .ready = viewModel.exportState else {
            Issue.record("Expected .ready state, got \(viewModel.exportState)")
            return
        }
    }

    @Test("exporting with nothing to export bounces back to idle instead of getting stuck")
    func generateCSVEmptyError() async throws {
        let jobApplicationService = MockJobApplicationService()
        await jobApplicationService.setExportError(JobApplicationServiceError.emptyRecords)
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.generateCSVFile()

        #expect(viewModel.exportState == .idle)
    }

    @Test("any other export failure also bounces back to idle")
    func generateCSVOtherError() async throws {
        let jobApplicationService = MockJobApplicationService()
        await jobApplicationService.setExportError(JobTrackerError.generalError)
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.generateCSVFile()

        #expect(viewModel.exportState == .idle)
    }

    @Test("tapping export again mid-export doesn't start a second one")
    func generateCSVWhileGenerating() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)
        viewModel.exportState = .generating

        await viewModel.generateCSVFile()

        #expect(viewModel.exportState == .generating)
    }

    @Test("tapping export again after one is ready doesn't overwrite it")
    func generateCSVWhileReady() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)
        let existingItem = CSVExportItem(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent("existing.csv"))
        viewModel.exportState = .ready(existingItem)

        await viewModel.generateCSVFile()

        #expect(viewModel.exportState == .ready(existingItem))
    }

    @Test("resetting while an export is still running is ignored")
    func resetExportWhileGenerating() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)
        viewModel.exportState = .generating

        viewModel.resetExportStateIfNeeded()

        #expect(viewModel.exportState == .generating)
    }

    @Test("resetting after an export cleans up the file and returns to idle")
    func resetExportWhileReady() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("reset-test.csv")
        try "data".write(to: fileURL, atomically: true, encoding: .utf8)
        viewModel.exportState = .ready(CSVExportItem(fileURL: fileURL))

        viewModel.resetExportStateIfNeeded()

        #expect(viewModel.exportState == .idle)
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test("erasing data flips the erasing flag on, then back off when it's done")
    func eraseDataTogglesFlag() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.eraseData()

        #expect(!viewModel.isErasing)
    }

    @Test("erasing data clears out any pending export along with everything else")
    func eraseDataSuccess() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("erase-test.csv")
        try "data".write(to: fileURL, atomically: true, encoding: .utf8)
        viewModel.exportState = .ready(CSVExportItem(fileURL: fileURL))

        await viewModel.eraseData()

        #expect(viewModel.exportState == .idle)
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
    }

    @Test("a failed erase doesn't leave the screen stuck mid-erase")
    func eraseDataFailure() async throws {
        let jobApplicationService = MockJobApplicationService()
        await jobApplicationService.setDeleteAllError(JobTrackerError.generalError)
        let tipService = MockTipJarService()
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.eraseData()

        #expect(!viewModel.isErasing)
    }

    @Test("a successful tip shows the thank-you message")
    func purchaseSuccess() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        tipService.purchaseResult = true
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.purchase(makePackage())

        #expect(viewModel.showThankYouMessage)
    }

    @Test("a failed tip never shows the thank-you message")
    func purchaseFailure() async throws {
        let jobApplicationService = MockJobApplicationService()
        let tipService = MockTipJarService()
        tipService.purchaseError = TipJarError.offeringNotFound
        let coordinator = SettingsCoordinator(modelContainer: try previewContainer())
        let viewModel = SettingsViewModel(jobApplicationService: jobApplicationService, tipService: tipService, coordinator: coordinator)

        await viewModel.purchase(makePackage())

        #expect(!viewModel.showThankYouMessage)
    }
}
