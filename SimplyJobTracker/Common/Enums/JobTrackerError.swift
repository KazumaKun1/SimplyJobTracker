//
//  JobTrackerError.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/5/26.
//

import Foundation

enum JobTrackerError: Error {
    case generalError
}

extension JobTrackerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .generalError: "Oops! Something is wrong."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .generalError: "Uh oh! Please try that action again."
        }
    }
}
