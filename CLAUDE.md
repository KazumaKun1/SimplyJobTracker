# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Commands

Xcode project, no CocoaPods/SwiftLint/SwiftFormat. One SPM dependency: `RevenueCat` (tip jar). Run from the repo root.

```bash
# Build
xcodebuild -project SimplyJobTracker.xcodeproj -scheme SimplyJobTracker -destination 'generic/platform=iOS Simulator' build

# Test (unit tests: Swift Testing; UI tests: XCTest)
xcodebuild test -project SimplyJobTracker.xcodeproj -scheme SimplyJobTracker -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16'

# Single unit test (replace <Suite>/<testName> with the Swift Testing suite and test function)
xcodebuild test -project SimplyJobTracker.xcodeproj -scheme SimplyJobTracker -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' -only-testing:SimplyJobTrackerTests/<Suite>/<testName>
```

- iOS 18.6 deployment target (app + widget; the 26.5 project default only applies to test targets). Swift 6, strict concurrency, `-default-isolation=MainActor`: types are MainActor by default, so opt out (`actor`/`nonisolated`) only for intentional background work. The widget target builds with Swift 5.
- **RevenueCat key**: `Common/Resources/Config.xcconfig` is committed with an empty `REVENUECAT_API_KEY` and optionally includes the gitignored `Secrets.xcconfig` (same folder), which holds the real key. `ci_scripts/ci_post_clone.sh` (Xcode Cloud) writes `Secrets.xcconfig` from the `REVENUECAT_API_KEY` env var. The key flows through `INFOPLIST_KEY_REVENUECAT_API_KEY` into Info.plist. `Constants.revenueCatAPIKey` is `String?` (`nil` if missing/blank): the app skips `Purchases.configure`, and `TipJarServiceImpl` throws `.notConfigured` (guards on `Purchases.isConfigured`), so Settings shows "Tipping Unavailable" instead of crashing. Never touch `Purchases.shared` without that guard.
- `Main/Tips.storekit` is a local StoreKit config for testing the tip jar in the Simulator.
- CI runs on Xcode Cloud (it replaced an earlier GitHub Actions workflow, so there is no `.github/workflows`); `ci_scripts/ci_post_clone.sh` is its only repo-side config. Tests cover enums, extensions, models, services, and view models (mocks in `SimplyJobTrackerTests/Mocks/`, in-memory `TestModelContainer`). UI tests: only `AddJobApplicationUITests`. Coverage is partial, so check the area you're touching.

## Architecture

**Coordinators + `@Observable` view models**, no DI framework; each feature builds its own dependencies.

- `TabCoordinator` (root, created in `SimplyJobTrackerApp` with the shared `ModelContainer`) owns `HomeCoordinator` and `SettingsCoordinator`, one `AppTab` case each.
- `AppCoordinatorView` renders the `TabView`; each tab gets a `NavigationStack(path:)` + `.navigationDestination(for:)` and an `.alert(...)`; Home also gets `.sheet(item:)`.
- Protocols in `Common/Coordinators/Common`: `NavigationCoordinator` (`NavigationRoute`, `path`, `build(route:)`, default `navigate(to:)`/`pop()`) and `AlertCoordinator` (`presentAlert` + queue, so alerts show in order). Sheets use a route enum (e.g. `HomeSheetRoute`) with `build(sheet:)`.
- View models hold a `weak` coordinator and their services; they never touch SwiftData or navigation state directly.

**Data layer**: `@Model` classes live in `Features/Home/Model` (`JobApplication`, `Interview`, `JobApplicationFilter`). Views read via `@Query`; writes go through services. Services use different isolation, so follow the one you're extending:

- `JobApplicationService` (`protocol: Actor`) / `JobApplicationServiceImpl` (`@ModelActor`): background writes. **Every mutation must end with `WidgetCenter.shared.reloadAllTimelines()`** or the widget goes stale. Also used by `SettingsCoordinator` for CSV export and bulk delete.
  - Intentional exception: `EditJobApplicationView` saves status changes via `modelContext.save()` + widget reload directly from the view. Don't extend this pattern.
  - Intentional exception: `ApplicationDetailsView` toggles `isFavorite` straight on the model (autosaves; no widget reload since the widget only shows status counts).
- `JobApplicationDeletionService` (`Common/Services`): `protocol: AnyObject`, `final class` on the **main** `ModelContext`, for deleting from the edit screen. Don't fold it into the `@ModelActor` service: a background delete left the row in the `@Query` list when the `@Bindable` model had unsaved edits. Reloads the widget. `EditJobApplicationViewModel.deleteJobApplication` is sync: delete, then `coordinator?.popToRoot()`.
- `InterviewService` (`protocol: AnyObject`) / `InterviewServiceImpl` (`final class`, plain `ModelContext`). No widget reload, since the widget doesn't show interview data.

## Conventions

- **Views**: each screen is `FeatureNameView.swift` (just `body`) plus `FeatureNameView+Extensions.swift` with subviews as nested types under `// MARK:` sections. Don't create standalone files for screen-local subviews.
- **Feature layout**: multi-screen features (`Features/Home`) keep `Coordinators/`, `Model/`, `Services/`, `Intents/` at the feature root, with a folder per screen (`View/`, `View/Extensions/`, and `ViewModel/` only if the screen owns state). Single-screen features (`Features/Settings`) put `Coordinators/`, `View/`, `ViewModel/` directly under the feature. Feature-specific services go in the feature's `Services/`, not `Common/Services`.
- **Shared pieces** (`Common/`): `ScreenContainer` (standard screen wrapper with optional bottom-trailing overlay), `HeaderView` (section header with optional leading/trailing content), `Binding<String?>.unwrapped(with:)` (optional-String model property to `TextField`, empty maps to `nil`), `JobTrackerError` (generic fallback `LocalizedError`; prefer a specific error type when the message differs).
- **Accessibility**: Home has deliberate VoiceOver support (labels/values/hints/traits, plural-aware strings like `"^[\(count) interview](inflect: true)"`, `AccessibilityNotification.LayoutChanged().post()` after filter changes). Match this in new Home UI.
- **No localization**: UI strings are hardcoded English.

## Feature notes

- **Favorites**: `JobApplication.isFavorite` is shipped and filterable (toolbar star, filter tag, list-card star), not a stub.
- **CSV export**: `CSVExporter.escape` prefixes fields starting with `=`, `+`, `-`, `@` with `'` to prevent formula injection. Preserve this. `CSVExportItem` is `Transferable`, so `SettingsView` passes it straight to `ShareLink` once `exportState` is `.ready`. `JobApplicationExportRow` decouples export from the `@Model`.
- **Google Drive backup**: Settings card is a "coming soon" placeholder with no backend.
- **Health check**: `ApplicationHealthCheckServiceImpl` uses Apple's on-device FoundationModels (`LanguageModelSession`, `generating: ApplicationHealthAssessment.self`), not a network call or Claude. `@available(iOS 26.0, *)` only; throws `.modelUnavailable` / `.generationFailed`. `ApplicationHealthCheckViewModel` drives `idle/loading/loaded/failed`. The prompt precomputes a "recency signal" bucket from days since last activity; keep that rather than leaving day math to the small model.
- **App Intents**: `Features/Home/Intents/` has four intents (`AddJobApplicationIntent`, `CountApplicationIntent`, `ApplicationSummaryIntent`, `LatestApplicationIntent`) registered in `SimplyJobTrackerShortcuts`. `JobApplicationEntity` is the `AppEntity` wrapper, separate from the SwiftData model.
- **Standing TODOs**: `NavigationCoordinator.swift` (arrays of coordinators in `TabCoordinator`) and `AppCoordinatorView.swift` (concrete tab types only).

## Widget extension

`SimplyJobTrackerWidget` (`systemSmall` only) shows application counts per `JobApplicationStatus`. It doesn't follow the Coordinator/ViewModel pattern (stateless `TimelineEntry` views).

- **Shared files**: `JobApplicationStatus.swift`, `SharedModelContainer.swift`, `JobApplication.swift`, `Interview.swift` belong to both targets (file-system-synchronized group exceptions in `project.pbxproj`). If you rename or move one, re-check target membership in Xcode. Status color assets are duplicated in both asset catalogs; keep them in sync.
- **Store**: `SharedModelContainer.shared` opens the SwiftData store in the App Group (`Constants.appGroupID`, `group.arviejhay.SimplyJobTracker`). The app must keep writing through that store or the widget shows stale/empty data.
- **Refresh**: `Provider` fetches with a plain `ModelContext` and returns `Timeline(entries:policy: .never)`, so it refreshes only when `reloadAllTimelines()` is called after writes.
