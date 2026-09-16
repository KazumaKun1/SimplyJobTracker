//
//  TotalOnlyView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/15/26.
//

import SwiftUI
import WidgetKit

struct TotalOnlyView: View {
    let numberOfApplications: Int
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("\(numberOfApplications)")
                .font(.system(size: 56, weight: .bold, design: .default))
            Text(numberOfApplications == 1 ? "Job Application" : "Job Applications")
                .font(.subheadline)
        }
    }
}
