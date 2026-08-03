//
//  NavigationCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/1/26.
//

import SwiftUI

// TODO: - Further implement this for arrays of coordinators in TabCoordinator

protocol NavigationCoordinator<NavigationRoute>: AnyObject {
    associatedtype NavigationRoute: Hashable
    associatedtype Content: View
    
    var path: NavigationPath { get set }
    
    func build(route: NavigationRoute) -> Content

    func navigate(to route: NavigationRoute)
    func pop()
}

extension NavigationCoordinator {
    func navigate(to route: NavigationRoute) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
