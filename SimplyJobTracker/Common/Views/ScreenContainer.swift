//
//  ScreenContainer.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/5/26.
//

import SwiftUI

struct ScreenContainer<Content: View, Overlay: View>: View {
    @ViewBuilder var content: Content
    @ViewBuilder var overlay: Overlay

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GeometryReader { proxy in
                ScrollView {
                    Group {
                        content
                    }
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }

            overlay
        }
    }
}

extension ScreenContainer where Overlay == EmptyView {
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
        self.overlay = EmptyView()
    }
}
