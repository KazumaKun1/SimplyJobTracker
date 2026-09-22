//
//  ApplicationHealthStatus.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

import FoundationModels

@available(iOS 26.0, *)
@Generable
enum ApplicationHealthStatus {
    case thriving
    case steady
    case needsAttention
    case stale
}
