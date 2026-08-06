//
//  AlertCoordinator.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 8/5/26.
//

import SwiftUI

struct AlertButton {
    let title: String
    let role: ButtonRole?
    let action: () -> Void
    
    init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.action = action
    }
}

struct AlertConfig: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    init(title: String, message: String? = nil, primaryButton: AlertButton, secondaryButton: AlertButton? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

protocol AlertCoordinator: AnyObject {
    var presentAlert: AlertConfig? { get set }
    var alertQueue: [AlertConfig] { get set }

    func presentAlert(_ alert: AlertConfig)
    func dismissAlert()
}

extension AlertCoordinator {
    func presentAlert(_ alert: AlertConfig) {
        guard presentAlert == nil else {
            alertQueue.append(alert)
            return
        }
        presentAlert = alert
    }

    func dismissAlert() {
        presentAlert = nil

        guard !alertQueue.isEmpty else { return }

        Task { @MainActor in
            presentAlert = alertQueue.removeFirst()
        }
    }
}
