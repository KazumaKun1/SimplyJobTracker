//
//  HeaderView.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/3/26.
//

import SwiftUI

typealias ViewContentBuilder<Content: View> = () -> Content

struct HeaderView<Leading: View, Trailing: View>: View {
    let text: String
    let height: CGFloat
    let leadingContent: ViewContentBuilder<Leading>
    let trailingContent: ViewContentBuilder<Trailing>
    
    init(text: String,
         height: CGFloat = 0,
         @ViewBuilder leadingContent: @escaping ViewContentBuilder<Leading> = { EmptyView() },
         @ViewBuilder trailingContent: @escaping ViewContentBuilder<Trailing> = { EmptyView() }) {
        self.text = text
        self.height = height
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
            leadingContent()
            Spacer()
            trailingContent()
        }
        .frame(height: height != 0 ? height : nil)
    }
}

#Preview {
    HeaderView(text: "HEADER NAME")
}
