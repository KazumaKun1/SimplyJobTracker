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
    var color: Color = .appBackground
    var scrollTrigger: AnyHashable? = nil
    
    @State private var containerHeight: CGFloat = 0
    @State private var pendingScrollToBottom = false
    @State private var scrollWorkItem: DispatchWorkItem?
    private let bottomID = "screenContainerBottom"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            color.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    Group {
                        content
                    }
                    .frame(minHeight: containerHeight)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { _ in
                        // Content height can settle across several layout passes
                        // (e.g. a conditionally-shown section), so debounce: only
                        // scroll once the height has stopped changing for a beat.
                        guard pendingScrollToBottom else { return }
                        scrollWorkItem?.cancel()
                        let workItem = DispatchWorkItem {
                            pendingScrollToBottom = false
                            withAnimation {
                                proxy.scrollTo(bottomID, anchor: .bottom)
                            }
                        }
                        scrollWorkItem = workItem
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
                    }

                    Color.clear.frame(height: 1)
                        .id(bottomID)
                }
                .scrollBounceBehavior(.basedOnSize)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { newHeight in
                    containerHeight = newHeight
                }
                .onChange(of: scrollTrigger) { _, _ in
                    pendingScrollToBottom = true
                }
            }

            overlay
        }
    }
}

extension ScreenContainer where Overlay == EmptyView {
    init(color: Color = .appBackground,
         scrollTrigger: AnyHashable? = nil,
         @ViewBuilder content: () -> Content) {
        self.color = color
        self.scrollTrigger = scrollTrigger
        self.content = content()
        self.overlay = EmptyView()
    }
}
