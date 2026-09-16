//
//  StatusView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/16/26.
//

import SwiftUI

struct StatusView: View {
    let total: Int
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Text("\(total)")
                .fontWeight(.semibold)
                .foregroundStyle(color)
            Text(title)
                .foregroundStyle(color.opacity(0.8))
        }
    }
}
