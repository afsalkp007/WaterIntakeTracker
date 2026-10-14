# 💧 WaterIntakeTracker

A modern, fluid SwiftUI iOS application designed to help users stay effortlessly hydrated throughout their day. Built with clean **MVVM architecture**, **SwiftData** for local persistence, **UserNotifications** for smart reminder scheduling, and **Swift Charts** for weekly hydration analytics.

Supports **iOS 17.0+**, **Light & Dark Mode**, **Dynamic Type (Accessibility)**, and **Portrait & Landscape Orientations**.

---

## 📸 Screenshots

<img width="256" height="556" src="https://github.com/user-attachments/assets/2c2ee22a-4518-40a6-a575-2ea82f0177af" />
<img width="256" height="556" src="https://github.com/user-attachments/assets/fde9870d-0600-4e3c-a7ca-db84ce1ad35e" />



> [!TIP]
> **Adding Your Screenshots**:
> 1. Create a `screenshots/` directory in the project root: `mkdir screenshots`
> 2. Save your screenshots as `dashboard_light.png`, `dashboard_dark.png`, `dashboard_landscape.png`, `analytics.png`, `custom_log.png`, and `settings.png`.

---

## ✨ Features

- 🎯 **Custom Daily Hydration Goal**: Set daily intake goals (e.g. 2,000 ml or 2.5L) with fast presets or fine-grained sliders.
- 🌊 **Dynamic Wave Progress Indicator**: Real-time fluid wave animation showing hydration percentage, current intake, and remaining target.
- ⚡ **One-Tap Quick Logging**: Log standard drink sizes in a single tap:
  - 🍵 Small Cup (150 ml)
  - 🥛 Standard Glass (250 ml)
  - ☕ Mug (350 ml)
  - 🍼 Bottle (500 ml)
- 🧃 **Multi-Beverage Support**: Log 7 distinct drink types (Water, Sparkling, Tea, Coffee, Electrolytes, Juice, Infused Water) with custom net hydration absorption factors.
- 🌓 **Full Light & Dark Mode Support**: Adaptive system colors and contrast gradients tuned for both vibrant daytime use and low-light environments.
- 📱 **Portrait & Landscape Adaptive**: Responsive dual-column layout in landscape on iPhone/iPad and optimized fluid layout in portrait.
- 🔤 **Dynamic Type (Accessibility)**: Uses semantic text styles and `@ScaledMetric` to scale typography and UI components gracefully with system accessibility text sizes.
- 🔔 **Smart Local Hydration Reminders**:
  - Customizable reminder intervals (every 1, 1.5, 2, or 3 hours).
  - Waking window configuration (e.g. 8:00 AM to 9:00 PM).
  - Motivational reminder notifications that change throughout the day.
  - "Send Test Reminder" button to verify delivery in 3 seconds.
- 📊 **Weekly Analytics & Streaks**:
  - Swift Charts visual breakdown of intake across the last 7 days against your goal line.
  - Daily streak tracking counter.
  - Full history timeline with swipe-to-delete.
- 💾 **100% On-Device Persistence**: Powered by Apple's modern **SwiftData** engine with zero external third-party dependencies.
- 🛡️ **GitHub-Safe**: Fully isolated, no third-party API keys or sensitive credentials required. Includes a comprehensive `.gitignore`.

---

## 🏗️ Project Architecture

The project follows a clean **Model-View-ViewModel (MVVM)** pattern with dedicated service layers and dependency injection:

```
WaterIntakeTracker/
├── Models/
│   ├── DrinkType.swift                     # Beverage types, SF symbols, colors & hydration factors
│   └── WaterLog.swift                      # SwiftData persistence model (@Model)
├── Services/
│   ├── HydrationCalculator.swift           # Core calculation engine (intake, streaks, summaries)
│   ├── NotificationServiceProtocol.swift   # Protocol for testability & dependency injection
│   ├── NotificationManager.swift           # UserNotifications scheduler & authorization
│   └── MockNotificationService.swift       # Test mock for notifications
├── ViewModels/
│   ├── DashboardViewModel.swift            # State & operations for the primary tracker dashboard
│   └── HistoryViewModel.swift              # Weekly aggregations, stats & log management
├── Views/
│   ├── DashboardView.swift                 # Main tracking screen with portrait/landscape adaptivity
│   ├── HistoryView.swift                   # Analytics tab with Swift Charts & drink timeline
│   ├── GoalSettingsView.swift              # Goal target, reminder intervals & notification controls
│   ├── LogCustomDrinkSheet.swift           # Modal for logging custom volume & beverage types
│   └── Components/
│       ├── WaveProgressView.swift          # Custom animated wave filling shape & ring
│       ├── QuickAddCard.swift              # One-tap preset container grid
│       └── IntakeHistoryRow.swift          # Entry row with icon, time, and net hydration
├── ContentView.swift                       # TabView hosting Today, Analytics, and Settings
└── MyApp.swift                             # App lifecycle & SwiftData ModelContainer setup
```

---

## 🧪 Testing Suite

The project includes a multi-layered testing suite organized under `WaterIntakeTrackerTests/`:

### 1. Unit Tests (`WaterIntakeTrackerTests/UnitTests/`)
- **`DrinkTypeTests.swift`**: Tests beverage enumeration, hydration factors (e.g. coffee discount, electrolyte bonus), and SF symbol mapping.
- **`WaterLogTests.swift`**: Tests persistence entity properties, initialization defaults, and net hydration calculation.
- **`HydrationCalculatorTests.swift`**: Tests daily summation, consecutive day streaks, broken streak detection, 7-day summaries, and unit conversions.
- **`DashboardViewModelTests.swift`**: Tests greeting generation, today log filtering, and goal completion triggers.
- **`HistoryViewModelTests.swift`**: Tests 7-day averages, goal-met day counting, and log deletion.
- **`NotificationServiceTests.swift`**: Tests reminder scheduling intervals, waking hours boundaries, and cancellation using `MockNotificationService`.

### 2. Integration Tests (`WaterIntakeTrackerTests/IntegrationTests/`)
- **`SwiftDataPersistenceTests.swift`**: Tests in-memory `ModelContainer`, CRUD operations, `#Predicate` queries, and sorting.
- **`HydrationTrackingFlowIntegrationTests.swift`**: Tests end-to-end full day user simulation (wake-up glass -> coffee -> workout electrolytes -> evening hydration -> goal achievement -> streak increment -> entry deletion).

### 3. Snapshot / View Rendering Tests (`WaterIntakeTrackerTests/SnapshotTests/`)
- **`ComponentSnapshotTests.swift`**: Uses Apple's native `ImageRenderer` (iOS 16+) to render visual snapshots of `WaveProgressView` (at 0%, 50%, and 100%+ goal achieved), `QuickAddCard`, and `IntakeHistoryRow`, asserting valid non-nil image bitmaps and retina dimensions.
- **`SnapshotTestHelper.swift`**: Reusable SwiftUI snapshot harness.

### 4. Full Pipeline Integration Tests (`WaterIntakeTrackerTests/TestRunner.swift`)
- End-to-end integration test case (`FullPipelineIntegrationTests: XCTestCase`) verifying all models, services, ViewModels, and visual components simultaneously.

---

## 🔒 GitHub & Security Readiness

This repository is safe and ready to be committed and pushed to GitHub:
- ✅ **`.gitignore`** is configured to ignore all local Xcode user state (`xcuserdata/`), `DerivedData/`, build artifacts, macOS `.DS_Store`, and environment secrets.
- ✅ No API keys, credentials, or personal tokens are embedded in the code.
- ✅ All user hydration logs and settings are stored locally on the device via SwiftData and `UserDefaults`.

---

## 🚀 Getting Started

### Prerequisites
- macOS Sonoma or macOS Sequoia / latest
- Xcode 15.0+ or Xcode 16.0+
- **Minimum Deployment Target**: iOS 17.0

### Opening and Running the Project
1. Open `WaterIntakeTracker.xcodeproj` in Xcode:
   ```bash
   open WaterIntakeTracker.xcodeproj
   ```
2. Select an iOS Simulator (e.g. **iPhone 15 / 16 / 17 / 18 Pro**) from the target device menu.
3. Press **⌘ + R** (Cmd + R) to build and run the app.
4. To run the full test suite, press **⌘ + U** in Xcode.

---

## 📱 Tech Stack

- **UI Framework**: SwiftUI (iOS 17.0+)
- **Charts**: Swift Charts
- **Persistence**: SwiftData
- **Notifications**: UserNotifications framework
- **Haptics**: UIKit (`UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`)
