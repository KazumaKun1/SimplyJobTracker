//
//  FilterView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/12/26.
//

import SwiftUI

struct FilterView: View {
    @Binding var filter: JobApplicationFilter

    var body: some View {
        ScreenContainer(color: .cardBackground, scrollTrigger: filter.dateContainer.rangePreset == .custom) {
            VStack {
                FilterHeader()
                FavoriteSection(isFavorite: $filter.isFavorite)
                StatusSection(currentStatus: $filter.status)
                Divider()
                    .padding(.vertical)
                DateSection(container: $filter.dateContainer)
            }
            .padding(.horizontal)
            .padding(.top, 40)
            .padding(.bottom)
            .presentationBackground(.cardBackground)
            .presentationDetents([.fraction(0.7)])
        }
    }
}

#Preview {
    FilterView(filter: .init(projectedValue: .constant(.init())))
}
