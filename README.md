<img width="150" height="150" alt="appicon" src="https://github.com/user-attachments/assets/f76c76c4-c19c-48b2-94c1-b411aacdb823" />

# SimplyJobTracker

A SwiftUI + SwiftData iOS app for tracking job applications — status, interviews, and activity over time — without spreadsheets.

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

Build and run the `SimplyJobTracker` scheme on an iOS Simulator or device. One SPM dependency, `RevenueCat` (`purchases-ios-spm`), used by the Settings tip jar — resolves automatically when you open the project in Xcode. You'll also need `Common/Resources/Config.xcconfig` with a `REVENUECAT_API_KEY` set (wired through an `INFOPLIST_KEY_REVENUECAT_API_KEY` build setting into Info.plist).

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

This is a solo, human-directed project — I designed the features, architecture, and UI myself and wrote/reviewed every change. I used AI coding assistants (Claude Code) throughout as a pair-programming tool: generating boilerplate, drafting implementations from a spec I gave it, and helping debug — not as an autonomous agent building the app on its own.

## Screenshots (App)
<img width="250" height="544" alt="simulator_screenshot_D5DA421D-1325-45F4-9694-AE8AE0B9F2A0" src="https://github.com/user-attachments/assets/67673a2f-8f71-41f8-8b40-c24900c3b756" />
<img width="250" height="544" alt="simulator_screenshot_F33E18DB-E1AF-404D-8599-8E36D389E9E2" src="https://github.com/user-attachments/assets/939c270b-fb98-4709-8a48-244e6019cffa" />
<img width="250" height="544" alt="simulator_screenshot_74060EED-AE73-4829-9E02-DD867746C68B" src="https://github.com/user-attachments/assets/bb08402f-5a82-4bf6-b8df-baf065c17a8b" />
<img width="250" height="544" alt="simulator_screenshot_418AB294-FB42-4814-975D-FDAEB5D573CA" src="https://github.com/user-attachments/assets/47b44789-27f9-4ad7-8ce9-561f47445cd9" />
<img width="250" height="544" alt="simulator_screenshot_55A0AE3B-4D79-4581-A237-9F7DE09B7C87" src="https://github.com/user-attachments/assets/85d18d3f-d2b4-4957-a6a0-aaa3effba2c3" />
<img width="250" height="544" alt="simulator_screenshot_C5C4BBD0-78BA-4B70-8838-83BADAB54356" src="https://github.com/user-attachments/assets/66249410-ac9b-46ca-a5bb-7fedba6bc4f2" />

## Screenshots (Widget)
<img width="86" height="82" alt="Screenshot 2026-09-16 at 10 50 43 PM" src="https://github.com/user-attachments/assets/2edcce90-9a28-40a2-9d66-2c6bd90dcd75" />
<img width="162" height="78" alt="Screenshot 2026-09-16 at 10 50 31 PM" src="https://github.com/user-attachments/assets/2f2829b9-f4d9-4519-a029-c57521f794c3" />
<img width="156" height="169" alt="Screenshot 2026-09-16 at 10 50 13 PM" src="https://github.com/user-attachments/assets/c1ef55e1-88f8-44b6-b530-478082eee676" />
