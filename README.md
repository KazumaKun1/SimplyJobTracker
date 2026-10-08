<img width="150" height="150" alt="appicon" src="https://github.com/user-attachments/assets/f76c76c4-c19c-48b2-94c1-b411aacdb823" />

# SimplyJobTracker

A SwiftUI + SwiftData iOS app for tracking job applications, status, interviews, and activity over time without spreadsheets.

## Features

- **Overview dashboard** — swipeable status tiles (Applied, Interviewing, Offer, Rejected, Ghosted) with live counts, tap a tile to filter
- **Last 7 days activity** — a compact per-day status strip, tap a day to filter the list to that date
- **Application list** — cards showing role, company, status, favorite star, interview count, and a relative timestamp that keeps itself up to date
- **Favorites** — star an application to flag it, then filter down to favorites only
- **Filtering & search** — by favorite, status, and single date/date range, shown as removable filter tags; a separate search sheet does live substring search over role/company
- **Add / edit applications** — track role, company, status, 1–5 star rating, overall experience notes, feeling, date applied, and associated interviews (each with its own title, date, and description)
- **AI health check (iOS 26+)** — an on-device summary of an application's status and a suggested next action, generated locally with Apple's Foundation Models framework (no data leaves the device)
- **Siri Shortcuts** — add an application, get a status count, hear your latest application, or ask for a summary, all by voice via App Intents
- **CSV export** — export all applications to CSV (with formula-injection–safe escaping) and share via the system share sheet
- **Home-screen widget** — a small WidgetKit widget showing application counts by status
- **Tip jar** — optional in-app tips via RevenueCat, in Settings
- **Accessibility** — VoiceOver labels/values/hints and grouped elements throughout the Home screen and filters, plus haptic feedback on key interactions
- **Data stays on-device** — no account required; a "back up to Google Drive" option is planned but not yet implemented

## Requirements

- Xcode 26.6+
- iOS 18.6+ (deployment target)
- Swift 6

## Getting started

```bash
open SimplyJobTracker.xcodeproj
```

Build and run the `SimplyJobTracker` scheme on an iOS Simulator or device. One SPM dependency, `RevenueCat` (`purchases-ios-spm`), used by the Settings tip jar — resolves automatically when you open the project in Xcode. You'll also need `SimplyJobTracker/Common/Resources/Config.xcconfig` with a `REVENUECAT_API_KEY` set (wired through an `INFOPLIST_KEY_REVENUECAT_API_KEY` build setting into Info.plist).

To build or test from the command line, use the standard `xcodebuild build` / `xcodebuild test` invocations against the `SimplyJobTracker` scheme.

## Tech stack

- **SwiftUI** for the UI, **SwiftData** for persistence
- **WidgetKit** for the home-screen widget, sharing data with the app via an App Group
- **RevenueCat** (SPM) for the Settings tip jar
- **Swift Testing** for unit tests, **XCTest** for UI tests
- **App Intents** for Siri Shortcuts support
- **Foundation Models** (Apple's on-device LLM framework, iOS 26+) for the AI health check summary
- A lightweight coordinator pattern for navigation/alerts and `@Observable` view models

## Status

Actively developed, with a growing suite of Swift Testing unit tests and a starting XCTest UI test; CI runs the full test suite on every PR. Coverage is real but not exhaustive.

## Development

This is a solo, human-directed project. I designed the features, architecture, and UI myself and wrote/reviewed every change. I used AI coding assistants (Claude Code) throughout as a pair-programming tool: generating boilerplate, drafting implementations from a spec I gave it, and helping debug, not as an autonomous agent building the app on its own.

## Screenshots (IPhone Duo)
<img width="320" height="440" alt="Screenshot 2026-10-08 at 8 33 47 PM" src="https://github.com/user-attachments/assets/201be1f1-ea33-4e1a-9958-36697e3bea5d" />
<img width="320" height="440" alt="Screenshot 2026-10-08 at 8 34 07 PM" src="https://github.com/user-attachments/assets/8f7afab1-5994-4ed4-8337-07f22570c2d2" />
<img width="470" height="335" alt="Screenshot 2026-10-08 at 8 34 30 PM" src="https://github.com/user-attachments/assets/8b50d223-4eda-40a2-b7fd-5ec673298e4a" />
<img width="330" height="460" alt="Screenshot 2026-10-08 at 8 34 41 PM" src="https://github.com/user-attachments/assets/5cc775d5-f819-4b4c-ad0e-cca4f19b102d" />


## Screenshots (App)
<img width="250" height="544" alt="Screenshot iPhone 17e 10-08-2026 at 8 20 32 PM" src="https://github.com/user-attachments/assets/df5a8940-9553-4612-94dd-df8ebb666ce7" />
<img width="250" height="544" alt="Screenshot iPhone 17e 10-08-2026 at 8 20 09 PM" src="https://github.com/user-attachments/assets/9e00d344-419d-46a1-9dc1-c86e6a1f761c" />
<img width="250" height="544" alt="Screenshot iPhone 17e 10-08-2026 at 8 20 22 PM" src="https://github.com/user-attachments/assets/01ca05b0-b0c8-451c-a178-e98e22b735a4" />
<img width="250" height="544" alt="Screenshot iPhone 17e 10-08-2026 at 8 20 46 PM" src="https://github.com/user-attachments/assets/9e2ab90e-5519-41df-81b7-456f2e397392" />
<img width="250" height="544" alt="Screenshot iPhone 17e 10-08-2026 at 8 20 54 PM" src="https://github.com/user-attachments/assets/89679821-892d-404e-a8aa-c13f3c81f581" />
<img width="250" height="544" alt="Screenshot iPhone 17e 10-08-2026 at 8 21 00 PM" src="https://github.com/user-attachments/assets/c287377d-110b-49cb-8b28-c9ece3d5c19f" />


## Screenshots (Widget)
<img width="86" height="82" alt="Screenshot 2026-09-16 at 10 50 43 PM" src="https://github.com/user-attachments/assets/2edcce90-9a28-40a2-9d66-2c6bd90dcd75" />
<img width="162" height="78" alt="Screenshot 2026-09-16 at 10 50 31 PM" src="https://github.com/user-attachments/assets/2f2829b9-f4d9-4519-a029-c57521f794c3" />
<img width="156" height="169" alt="Screenshot 2026-09-16 at 10 50 13 PM" src="https://github.com/user-attachments/assets/c1ef55e1-88f8-44b6-b530-478082eee676" />
