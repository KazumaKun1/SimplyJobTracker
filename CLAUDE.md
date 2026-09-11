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

Deployment target is iOS 26.5, Swift 6 with strict concurrency and `-default-isolation=MainActor` — types are MainActor-isolated by default; only opt out (e.g. with `actor`/`nonisolated`) where background work is intentional (see the service layer below).

RevenueCat needs an API key: `Common/Resources/Config.xcconfig` defines `REVENUECAT_API_KEY`, wired through an `INFOPLIST_KEY_REVENUECAT_API_KEY` build setting into Info.plist. `Constants.revenueCatAPIKey` (`Common/Constants/Constants.swift`) reads it back out and `fatalError`s if it's missing — make sure `Config.xcconfig` is in place before building.

## Architecture

**Coordinator pattern with `@Observable` view models.** There is no dependency-injection framework; each feature owns and constructs its own dependencies.

- `TabCoordinator` (`Common/Coordinators`) is the root object, created once in `SimplyJobTrackerApp` with the shared `ModelContainer`. It owns one coordinator per tab (`HomeCoordinator`, `SettingsCoordinator`) and one `AppTab` case each.
- `AppCoordinatorView` renders the `TabView` and, for each tab, wraps that tab's coordinator in a `NavigationStack(path:)` + `.navigationDestination(for:)`. Home additionally gets a `.sheet(item:)` for its sheet routes; both tabs get an `.alert(...)` driven by the coordinator's `AlertCoordinator` conformance.
- Two small generic protocols in `Common/Coordinators/Common` drive this, and every feature coordinator conforms to them:
  - `NavigationCoordinator`: associated `NavigationRoute: Hashable`, a `path: NavigationPath`, and `build(route:) -> some View`. `navigate(to:)`/`pop()` are default implementations.
  - `AlertCoordinator`: `presentAlert: AlertConfig?` plus an `alertQueue`, so alerts triggered while one is already showing are queued and presented in order (see `HomeCoordinator`, `SettingsCoordinator`).
- Feature coordinators that need sheets also define a sheet route enum (e.g. `HomeSheetRoute`) and a `build(sheet:)` builder, following the same pattern as routes. Not every coordinator needs one — `SettingsCoordinator` has no sheets.
- View models (`@Observable`, e.g. `HomeViewModel`, `SettingsViewModel`) hold a `weak` reference back to their coordinator to trigger navigation/alerts, and hold the feature's service(s) for data operations. They never touch SwiftData or navigation state directly.

**Data layer**: SwiftData `@Model` classes live under each feature's `Model/` folder (`JobApplication`, `Interview`, both under `Features/Home/Main/Model`). Mutations go through a service, not directly through a `ModelContext` from the view layer — but the two existing services use different isolation strategies, so check which one you're extending:
- `JobApplicationService` is a `protocol: Actor`; `JobApplicationServiceImpl` is a `@ModelActor actor` conforming to it, constructed per-coordinator from the shared `ModelContainer`. This keeps SwiftData writes off the main actor while view models stay `@Observable`/MainActor. It's shared across features (e.g. `SettingsCoordinator` builds its own instance for CSV export and bulk delete).
- `InterviewService` is a plain `protocol: AnyObject`; `InterviewServiceImpl` is a `final class` holding a `ModelContext` directly (not actor-isolated). Follow whichever pattern the service you're touching already uses — don't silently convert one to the other.
- Views read data directly via `@Query` (see `HomeView`, `SettingsView`), and go through a service only for writes (create/delete/export).

**View file convention**: each screen is a `FeatureNameView.swift` containing only the top-level `body`, with all of its subviews defined as nested types in a matching `FeatureNameView+Extensions.swift` (e.g. `HomeView+Extensions.swift`, `EditJobApplicationView+Extensions.swift`, `SettingsView+Extensions.swift`). When adding subviews to an existing screen, put them in the `+Extensions.swift` file as `extension FeatureNameView { struct SomeSubview: View { ... } }`, grouped under `// MARK:` sections — don't create new standalone view files for screen-local subviews.

**Shared building blocks** (`Common/`):
- `ScreenContainer`: the standard screen wrapper — scrollable content plus an optional bottom-trailing `overlay` (e.g. a floating action button). Most feature screens should be built inside this rather than a raw `ScrollView`.
- `HeaderView`: a section header with a caption-style label plus optional leading/trailing content builders (see its use for section titles with an inline button, e.g. the search icon on the Home screen).
- `Binding<String?>.unwrapped(with:)` (`String+Extensions.swift`): bridges optional-`String` model properties to `TextField`, mapping empty string back to `nil` on write. Use this instead of hand-rolling optional bindings for text fields backed by optional model properties.
- `URL: Identifiable` (`URL+Extensions.swift`, `@retroactive`): lets a `URL?` drive `.sheet(item:)` directly (see `SettingsView`'s CSV export sheet) without wrapping it in an `Identifiable` box type.
- `ShareSheet` (`Common/Views`): a `UIViewControllerRepresentable` around `UIActivityViewController`, for presenting the system share sheet (e.g. sharing the exported CSV file) from SwiftUI.
- `JobTrackerError` (`Common/Enums`): a generic `LocalizedError` for surfacing a fallback "something went wrong" alert; prefer a feature/service-specific error type when the failure needs a distinct message.
- `Common/Classes/CSVExporter.swift` + `JobApplicationExportRow.swift`: build a CSV string from job applications and write it to a temp file (`CSVExporter.writeToTemporaryFile(_:)`); `JobApplicationExportRow` is a plain, `nonisolated`-init flattening of `JobApplication` for export, decoupled from the `@Model` type.

**Feature module layout** (see `Features/Home`): each feature is split into `Coordinators/`, `Model/`, `View/` (with a `View/Extensions/` subfolder for the `+Extensions.swift` files), and `ViewModel/`. A feature with its own service(s) (e.g. `Features/Settings/Main/Services/TipJarService.swift`) adds a `Services/` folder rather than putting the service in `Common/Services`. New features should follow this same folder shape.
