//
//  SimplyJobTrackerApp.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI
import SwiftData

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
        _coordinator = State(initialValue: TabCoordinator(modelContainer: sharedModelContainer))
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
        }
        .modelContainer(sharedModelContainer)
    }
}
