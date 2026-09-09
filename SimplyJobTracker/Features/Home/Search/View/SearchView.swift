//
//  SearchView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/8/26.
//

import SwiftUI

struct SearchView: View {
    var applications: [JobApplication]
    var onSelect: (JobApplication) -> ()
    
    @State private var searchText = ""
    
    private var filteredApplications: [JobApplication] {
        guard !searchText.isEmpty else { return applications }
        return applications.filter {
            ($0.company?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            ($0.role?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                JobApplicationList(jobApplications: filteredApplications) { application in
                    onSelect(application)
                }
                .padding(.horizontal)
            }
            .presentationDetents([.fraction(0.5)])
            .presentationBackground(.cardBackground2)
        }
        .searchable(text: $searchText, prompt: "Search by company or role")
    }
}
