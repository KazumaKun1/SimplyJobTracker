//
//  TipJarService.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/10/26.
//

import RevenueCat

enum TipJarError: Error {
    case offeringNotFound
}

protocol TipJarService {
    func fetchPackages() async throws -> [Package]
    func purchase(_ package: Package) async throws -> Bool
}

actor TipJarServiceImpl: TipJarService {
    func fetchPackages() async throws -> [Package] {
        let offerings = try await Purchases.shared.offerings()
        guard let packages = offerings.current?.availablePackages else {
            throw TipJarError.offeringNotFound
        }
        return packages
    }
    
    func purchase(_ package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        return !result.userCancelled
    }
}
