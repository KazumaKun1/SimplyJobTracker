//
//  JobApplicationDialogText.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/22/26.
//

nonisolated enum JobApplicationDialogText {
    static func roleCompanyFragment(role: String, company: String) -> String? {
        var parts: [String] = []
        if !role.isEmpty {
            parts.append("for \(role)")
        }

        if !company.isEmpty {
            parts.append("at \(company)")
        }

        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
