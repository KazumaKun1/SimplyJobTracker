//
//  SimplyJobTrackerApp.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct SimplyJobTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JobApplication.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var coordinator: TabCoordinator
    
    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif
        
        Purchases.configure(
            with: Configuration.Builder(withAPIKey: Constants.revenueCatAPIKey)
                .with(storeKitVersion: .storeKit2)
                .build()
        )
        
        _coordinator = State(initialValue: TabCoordinator(modelContainer: sharedModelContainer))
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
        }
        .modelContainer(sharedModelContainer)
    }
}
