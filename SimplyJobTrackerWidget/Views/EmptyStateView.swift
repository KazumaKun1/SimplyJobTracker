//
//  EmptyStateView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/15/26.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("No applications tracked")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                Text("Tap to add")
            }
            .font(.footnote)
            .foregroundStyle(.gray.opacity(0.7))
        }
    }
}
