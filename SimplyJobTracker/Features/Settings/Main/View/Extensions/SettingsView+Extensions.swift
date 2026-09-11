//
//  SettingsView+Extensions.swift
//  SimplyJobTracker
//
//  Created by Arviejhay Alejandro on 9/10/26.
//

import SwiftUI
import RevenueCat

// MARK: - Backup Feature
extension SettingsView {
    struct BackupView: View {
        var body: some View {
            HeaderView(text: "BACKUP")
            VStack {
                Text("Back up to Google Drive feature is coming soon")
                    .foregroundStyle(.gray)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.cardBackground)
            )
        }
    }
}

// MARK: - Data Privacy
extension SettingsView {
    struct DataPrivacyView: View {
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.shield")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    
                Text("Your data stays private")
                    .font(.headline)
                Text("Everything is stored only on this device. Nothing leaves it. Optional Drive backup is in the works.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.cardBackground)
            )
        }
    }
}

// MARK: - Tipping Jar
extension SettingsView {
    struct TippingJar: View {
        var shouldShowThankYou: Bool
        let packages: [Package]
        let onPurchase: (Package) -> ()
        
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: shouldShowThankYou ? "heart.fill" : "heart")
                    .font(.largeTitle)
                    .foregroundStyle(shouldShowThankYou ? .red : .primary)
                    .contentTransition(.symbolEffect(.replace))
                
                Text("Support this app")
                    .font(.headline)
                
                Text(shouldShowThankYou ? "Thank you—that genuinely helps." : "SimplyJobTracker is built and maintained independently. If it's helped you, a small tip goes a long way.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .contentTransition(.opacity)
                
                Group {
                    if !packages.isEmpty {
                        PackageView(packages: packages) { package in
                            onPurchase(package)
                        }
                        .opacity(shouldShowThankYou ? 0 : 1)
                    } else {
                        Text("Tipping Unavailable")
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
                }
                .frame(height: shouldShowThankYou ? 0 : nil, alignment: .top)
                .clipped()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.cardBackground)
            )
            .animation(.easeInOut(duration: 0.5), value: packages.isEmpty)
        }
    }
    
    struct PackageView: View {
        let packages: [Package]
        let action: (Package) -> Void
        
        var body: some View {
            HStack(spacing: 8) {
                ForEach(packages) { package in
                    Button {
                        action(package)
                    } label: {
                        VStack(spacing: 6) {
                            Text(package.storeProduct.localizedTitle)
                                .fontWeight(.semibold)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue)
                        )
                    }
                }
            }
            .transition(.opacity)
        }
    }
}

// MARK: - Data Section
extension SettingsView {
    struct DataSection: View {
        let exportCSVAction: () -> ()
        let deleteDataAction: () -> ()
        
        var body: some View {
            HeaderView(text: "DATA")
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    exportCSVAction()
                } label: {
                    Text("Export as CSV")
                }
                Divider()
                    .padding(.vertical)
                Button(role: .destructive) {
                    deleteDataAction()
                } label: {
                    Text("Clear all data")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.cardBackground)
            )
        }
    }
}
