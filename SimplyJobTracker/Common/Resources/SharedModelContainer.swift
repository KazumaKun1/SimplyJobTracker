//
//  SharedModelContainer.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import SwiftData
import Foundation

enum SharedModelContainer {
    static let shared: ModelContainer = make()
    
    private static func make() -> ModelContainer {
        let schema = Schema([
            JobApplication.self,
        ])
        
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupID) else {
            fatalError("App Group Container not found")
        }
        
        let storeURL = groupURL.appendingPathComponent("SimplyJobTracker.sqlite")
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
