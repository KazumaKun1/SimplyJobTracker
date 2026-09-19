# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

This is an Xcode project (no CocoaPods, no SwiftLint/SwiftFormat config). One SPM dependency: `RevenueCat` (`purchases-ios-spm`), used by the Settings tip jar. Use `xcodebuild` from the repo root, or open `SimplyJobTracker.xcodeproj` in Xcode.

```bash
# Build for the simulator
xcodebuild -project SimplyJobTracker.xcodeproj -scheme SimplyJobTracker -destination 'generic/platform=iOS Simulator' build

# Run all tests (unit tests use Swift Testing, UI tests use XCTest)
xcodebuild test -project SimplyJobTracker.xcodeproj -scheme SimplyJobTracker -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single unit test (Swift Testing target/suite/testname)
xcodebuild test -project SimplyJobTracker.xcodeproj -scheme SimplyJobTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SimplyJobTrackerTests/SimplyJobTrackerTests/example

# Open in Xcode
open SimplyJobTracker.xcodeproj
```

Deployment target is iOS 18.6 (main app and widget extension targets — the project-level default of 26.5 only applies to the test targets), Swift 6 with strict concurrency and `-default-isolation=MainActor` — types are MainActor-isolated by default; only opt out (e.g. with `actor`/`nonisolated`) where background work is intentional (see the service layer below). The widget extension target builds with Swift 5 and has no default actor isolation setting.

RevenueCat needs an API key: `Common/Resources/Config.xcconfig` defines `REVENUECAT_API_KEY`, wired through an `INFOPLIST_KEY_REVENUECAT_API_KEY` build setting into Info.plist. `Constants.revenueCatAPIKey` (`Common/Constants/Constants.swift`) reads it back out and `fatalError`s if it's missing — make sure `Config.xcconfig` is in place before building. `SimplyJobTracker/Main/Tips.storekit` is a local StoreKit configuration for exercising the tip jar in the Simulator without hitting the real RevenueCat backend.

`.github/workflows/CI.yml` runs on PRs/pushes to `main`: it generates `Config.xcconfig` from a `REVENUECAT_API_KEY` GitHub Actions secret, then runs the same `xcodebuild build`/`xcodebuild test` invocations shown above. Both test targets (`SimplyJobTrackerTests`, `SimplyJobTrackerUITests`) are currently unfilled Xcode templates with no real assertions, so CI passing doesn't yet indicate behavioral coverage — keep this in mind before treating a green build as validation of a change.

## Architecture

**Coordinator pattern with `@Observable` view models.** There is no dependency-injection framework; each feature owns and constructs its own dependencies.

- `TabCoordinator` (`Common/Coordinators`) is the root object, created once in `SimplyJobTrackerApp` with the shared `ModelContainer`. It owns one coordinator per tab (`HomeCoordinator`, `SettingsCoordinator`) and one `AppTab` case each.
- `AppCoordinatorView` renders the `TabView` and, for each tab, wraps that tab's coordinator in a `NavigationStack(path:)` + `.navigationDestination(for:)`. Home additionally gets a `.sheet(item:)` for its sheet routes; both tabs get an `.alert(...)` driven by the coordinator's `AlertCoordinator` conformance.
- Two small generic protocols in `Common/Coordinators/Common` drive this, and every feature coordinator conforms to them:
  - `NavigationCoordinator`: associated `NavigationRoute: Hashable`, a `path: NavigationPath`, and `build(route:) -> some View`. `navigate(to:)`/`pop()` are default implementations.
  - `AlertCoordinator`: `presentAlert: AlertConfig?` plus an `alertQueue`, so alerts triggered while one is already showing are queued and presented in order (see `HomeCoordinator`, `SettingsCoordinator`).
- Feature coordinators that need sheets also define a sheet route enum (e.g. `HomeSheetRoute`) and a `build(sheet:)` builder, following the same pattern as routes. Not every coordinator needs one — `SettingsCoordinator` has no sheets.
- View models (`@Observable`, e.g. `HomeViewModel`, `SettingsViewModel`) hold a `weak` reference back to their coordinator to trigger navigation/alerts, and hold the feature's service(s) for data operations. They never touch SwiftData or navigation state directly.

**Data layer**: SwiftData `@Model` classes live under each feature's `Model/` folder (`JobApplication`, `Interview`, `JobApplicationFilter`, all under `Features/Home/Model`). Mutations go through a service, not directly through a `ModelContext` from the view layer — but the two existing services use different isolation strategies, so check which one you're extending:
- `JobApplicationService` is a `protocol: Actor`; `JobApplicationServiceImpl` is a `@ModelActor actor` conforming to it, constructed per-coordinator from the shared `ModelContainer`. This keeps SwiftData writes off the main actor while view models stay `@Observable`/MainActor. It's shared across features (e.g. `SettingsCoordinator` builds its own instance for CSV export and bulk delete). Every mutating call (`createJobApplication`, `deleteJobApplication`, `deleteAllJobApplications`) ends with `WidgetCenter.shared.reloadAllTimelines()` so the home-screen widget stays in sync — keep that call when adding new mutations here. One documented exception: `EditJobApplicationView` saves a status change by calling `modelContext.save()` and `WidgetCenter.shared.reloadAllTimelines()` directly from the view layer (via `@Bindable`), bypassing the service — this is existing, intentional behavior for that one field, not a pattern to extend elsewhere.
- `InterviewService` is a plain `protocol: AnyObject`; `InterviewServiceImpl` is a `final class` holding a `ModelContext` directly (not actor-isolated). Follow whichever pattern the service you're touching already uses — don't silently convert one to the other. Unlike `JobApplicationServiceImpl`, its mutations (`addInterview`, `deleteInterview`) do not call `WidgetCenter.shared.reloadAllTimelines()`, since the widget only surfaces status counts, not interview data — keep it that way unless the widget starts showing interview info.
- Views read data directly via `@Query` (see `HomeView`, `SettingsView`), and go through a service only for writes (create/delete/export).

**View file convention**: each screen is a `FeatureNameView.swift` containing only the top-level `body`, with all of its subviews defined as nested types in a matching `FeatureNameView+Extensions.swift` (e.g. `HomeView+Extensions.swift`, `EditJobApplicationView+Extensions.swift`, `SettingsView+Extensions.swift`). When adding subviews to an existing screen, put them in the `+Extensions.swift` file as `extension FeatureNameView { struct SomeSubview: View { ... } }`, grouped under `// MARK:` sections — don't create new standalone view files for screen-local subviews.

**Shared building blocks** (`Common/`):
- `ScreenContainer`: the standard screen wrapper — scrollable content plus an optional bottom-trailing `overlay` (e.g. a floating action button). Most feature screens should be built inside this rather than a raw `ScrollView`.
- `HeaderView`: a section header with a caption-style label plus optional leading/trailing content builders (see its use for section titles with an inline button, e.g. the search icon on the Home screen).
- `Binding<String?>.unwrapped(with:)` (`String+Extensions.swift`): bridges optional-`String` model properties to `TextField`, mapping empty string back to `nil` on write. Use this instead of hand-rolling optional bindings for text fields backed by optional model properties.
- `JobTrackerError` (`Common/Enums`): a generic `LocalizedError` for surfacing a fallback "something went wrong" alert; prefer a feature/service-specific error type when the failure needs a distinct message.
- `Common/Services/CSVExport/`: `CSVExporter.writeToTemporaryFile(_:)` builds a CSV string from job applications and writes it to a temp file; `JobApplicationExportRow` is a plain, `nonisolated`-init flattening of `JobApplication` for export, decoupled from the `@Model` type; `CSVExportItem` wraps the resulting file `URL` as `Transferable` (`FileRepresentation`/`.commaSeparatedText`) so `SettingsView` can hand it straight to a `ShareLink` once `SettingsViewModel.exportState` becomes `.ready` — no `UIActivityViewController` wrapper needed for this flow.
- `Common/Resources/SharedModelContainer.swift`: the `ModelContainer` used by the widget extension (see below) to read `JobApplication` data from the same App Group store as the main app.

**Feature module layout**: a multi-screen feature (see `Features/Home`) keeps its feature-wide `Coordinators/` and `Model/` at the feature root, with each screen as a sibling folder (`Main/`, `ApplicationDetails/`, `EditApplication/`, `Filter/`, `Search/`) containing `View/` (with a `View/Extensions/` subfolder for the `+Extensions.swift` files) and a `ViewModel/` only if that screen owns state beyond what its parent hands it via binding/array — `ApplicationDetails`, `Filter`, and `Search` are presentation-only over `HomeCoordinator`/`HomeViewModel` state and have no `ViewModel/`. A single-screen feature (see `Features/Settings`) skips the extra screen-name nesting and puts `Coordinators/`, `View/`, `ViewModel/` directly under the feature folder; only add that nesting back if the feature grows a second screen. A feature with its own service(s) (e.g. `Features/Settings/Services/TipJarService.swift`) adds a `Services/` folder rather than putting the service in `Common/Services`. New features should follow whichever of these two shapes fits.

## Notable feature details

- **Favorites**: `JobApplication.isFavorite` is a shipped, filterable feature (star toggle in `ApplicationDetailsView`'s toolbar, capsule tag and toggle in `FilterView`, star shown on list cards) — don't treat it as a stub.
- **Accessibility**: the Home screen and its subviews (metrics tiles, daily-activity dots, filter tags, favorite toggle) carry deliberate VoiceOver support — `accessibilityLabel`/`accessibilityValue`/`accessibilityHint`/`accessibilityAddTraits`/`accessibilityElement(children:)`, plural-aware strings (e.g. `"^[\(count) interview](inflect: true)"`), and `AccessibilityNotification.LayoutChanged().post()` after filter changes. Match this level of care in any new Home UI.
- **CSV export safety**: `CSVExporter.escape` (`Common/Services/CSVExport/CSVExporter.swift`) prefixes any field starting with `=`, `+`, `-`, or `@` with a leading `'` to prevent CSV/formula injection when the export is opened in a spreadsheet app. Preserve this if you touch export formatting.
- **Google Drive backup**: the Settings "Back up to Google Drive" card is a visible but entirely unimplemented "coming soon" placeholder — there is no backend behind it yet.
- **No localization**: all UI strings are hardcoded English literals; there's no `.strings`/String Catalog infrastructure in place.
- Two standing TODOs worth knowing about before touching navigation: `NavigationCoordinator.swift` (further support for arrays of coordinators in `TabCoordinator`) and `AppCoordinatorView.swift` (currently sticks to concrete tab types since there's no plan to extend beyond two tabs).

## Widget extension

`SimplyJobTrackerWidget` is a separate WidgetKit extension target (`SimplyJobTrackerWidgetBundle` → `SimplyJobTrackerWidget: Widget`, `systemSmall` only) showing counts of applications per `JobApplicationStatus`.

- **Data sharing, not duplication**: the widget does not have its own copy of the model layer. `Common/Enums/JobApplicationStatus.swift`, `Common/Resources/SharedModelContainer.swift`, `Features/Home/Model/JobApplication.swift`, and `Features/Home/Model/Interview.swift` are added to the widget target as well as the main app target (Xcode file-system-synchronized group membership exceptions in `project.pbxproj`) — if you rename or move any of these four files, re-check that target membership in Xcode rather than assuming the synchronized group carries it over automatically. The per-status color assets (`Applied`, `Interviewing`, `Offers`, `Rejected`, `Ghosted`) are similarly duplicated between the app's and widget's `Assets.xcassets` rather than shared — keep both in sync if a status color changes.
- `SharedModelContainer.shared` opens the `JobApplication` SwiftData store from the App Group container (`Constants.appGroupID`, `group.arviejhay.SimplyJobTracker`) so both the app and the widget read the same on-disk data. The main app must keep writing through this same App Group store (it does today, via `JobApplicationServiceImpl`'s `ModelContainer`) or the widget will silently show stale/empty data.
- `Provider: TimelineProvider` (`JobApplicationEntryProvider.swift`) fetches directly with a plain `ModelContext(SharedModelContainer.shared)` — no service/actor layer here, since the widget process is short-lived and doesn't need the app's actor isolation. `Timeline(entries:policy: .never)` means the widget only refreshes when explicitly told to, which is why `JobApplicationServiceImpl` calls `WidgetCenter.shared.reloadAllTimelines()` after every write; forgetting that call on a new mutation will leave the widget stale.
- `JobApplicationEntry` (`Model/JobApplicationEntry.swift`) is the `TimelineEntry`; `Views/` holds the entry views (`WidgetEntryView`, `EmptyStateView`, `TotalOnlyView`, `TotalWithAllStatusView`, `TotalWithPositiveStatusView`, `Views/Common/StatusView.swift`) — this target does not follow the app's Coordinator/ViewModel pattern, since WidgetKit views are stateless renderings of a `TimelineEntry`, not a navigable app screen.
