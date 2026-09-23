//
//  MockTipJarService.swift
//  SimplyJobTrackerTests
//

import RevenueCat
@testable import SimplyJobTracker

@MainActor
final class MockTipJarService: TipJarService {
    var fetchPackagesResult: [Package] = []
    var fetchPackagesError: Error?
    var purchaseResult = true
    var purchaseError: Error?

    func fetchPackages() async throws -> [Package] {
        if let fetchPackagesError { throw fetchPackagesError }
        return fetchPackagesResult
    }

    func purchase(_ package: Package) async throws -> Bool {
        if let purchaseError { throw purchaseError }
        return purchaseResult
    }
}
