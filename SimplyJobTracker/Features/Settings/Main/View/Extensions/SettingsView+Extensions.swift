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
        let packages: [Package]
        let onPurchase: (Package) -> ()
        
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "heart")
                    .font(.largeTitle)
                Text("Support this app")
                    .font(.headline)
                Text("SimplyJobTracker is built and maintained independently. If it's helped you, a small goes a long way.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                
                HStack {
                    ForEach(packages) { package in
                        Button {
                            onPurchase(package)
                        } label: {
                            VStack {
                                Text(package.storeProduct.localizedTitle)
                                Text(package.storeProduct.localizedPriceString)
                            }
                        }
                    }
                }
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

// MARK: - Data Section
extension SettingsView {
    struct DataSection: View {
        var body: some View {
            HeaderView(text: "DATA")
            VStack(alignment: .leading, spacing: 0) {
                Button {

                } label: {
                    Text("Export as CSV")
                }
                Divider()
                    .padding(.vertical)
                Button(role: .destructive) {

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

#Preview {
    SettingsView(viewModel: .init(service: TipJarServiceImpl(), coordinator: .init()))
}
