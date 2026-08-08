# SimplyJobTracker

A SwiftUI + SwiftData iOS app for tracking job applications — status, interviews, and activity over time — without spreadsheets.

## Features

- **Overview dashboard** — swipeable status tiles (Applied, Interviewing, Offer, Rejected, Passed) with live counts, tap a tile to filter
- **Last 7 days activity** — a compact per-day status strip, tap a day to filter the list to that date
- **Application list** — cards showing role, company, status, interview count, and a relative timestamp ("2h ago") that keeps itself up to date
- **Filtering** — by status and by single date/date range, shown as removable filter tags
- **Add / edit applications** — track role, company, status, rating, overall experience notes, feeling, and associated interviews (edit flow in progress)

## Requirements

- Xcode 26.6+
- iOS 26.5+ (deployment target)
- Swift 6

## Getting started

```bash
open SimplyJobTracker.xcodeproj
```

Build and run the `SimplyJobTracker` scheme on an iOS Simulator or device. No external dependencies (no SPM packages, CocoaPods, etc.) — it's a plain Xcode project.

To build or test from the command line, see [CLAUDE.md](CLAUDE.md) for the exact `xcodebuild` invocations.

## Tech stack

- **SwiftUI** for the UI, **SwiftData** for persistence
- **Swift Testing** for unit tests, **XCTest** for UI tests
- A lightweight coordinator pattern for navigation/alerts and `@Observable` view models — see [CLAUDE.md](CLAUDE.md) for the architecture details

## Status

Actively developed. Current focus: an edit/detail flow for existing job applications.
