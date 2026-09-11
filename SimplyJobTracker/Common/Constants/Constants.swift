//
//  Constants.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/11/26.
//

import Foundation

enum Constants {
    static let revenueCatAPIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String,
              !key.isEmpty else {
            fatalError("RevenueCatAPIKey missing from Info.plist — check Config.xcconfig is set up.")
        }
        return key
    }()
}
