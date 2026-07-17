#  iOS games

iOS games is a robust, multi game iOS application built purely in SwiftUI. It provides an engaging suite of mini games alongside comprehensive statistics tracking, interactive map plotting for played sessions, and a daily local notification system.

## Features List
* **Multi Game Hub:** Includes three uniquely engaging mini games:
* 
  * **Tap Frenzy:** A fast paced tapping game that tests reaction speed.
  * **Light It Up:** A memory and reflex challenge involving a dynamic grid of lit cards.
  * **Quiz Rush:** A trivia game that fetches real time questions, requiring both speed and general knowledge.
  * 
* **Global Dark Theme:** An enforced, sleek dark aesthetic UI applied globally across all game modes, menus, and views.
* **Persistent Session Tracking:** Automatically tracks every finished game, permanently storing the score, exact timestamp, and the user's geographical location.
* **Advanced Statistics Dashboard:** A dedicated tab featuring dynamic, distinct bar charts (`SwiftUI.Charts`) that cleanly visualize the last 10 game sessions for each individual game mode without unwanted data stacking.
* **Interactive Map Visualization:** Uses iOS 17 `MapKit` features to drop a single unified "Total Games" pin at the location of the most recent session. Tapping the pin smoothly opens an interactive bottom sheet containing organized, collapsible accordion lists of all past scores.
* **Daily Challenge Reminders:** Leverages `UserNotifications` to let players set a specific time each day to receive local push notifications, encouraging them to beat their high scores.
* **One Click Sharing:** Includes a SwiftUI `ShareLink` integrated natively into the Game Over overlay, allowing players to instantly share their achievements via the iOS Share Sheet.

## Architecture Overview
* **UI Framework:** 100% SwiftUI with a `TabView` based routing system (`MainTabView`).
* **State Management:** Utilizes the `@State`, `@StateObject`, and `@ObservedObject` property wrappers for reactive, localized view states.
* **Data Persistence:** Relies on a Singleton pattern (`GameSessionManager.shared`) to encode/decode arrays of `GameSession` structs via `UserDefaults` for lightweight, persistent local storage. Persistent user settings and high scores are managed seamlessly via `@AppStorage`.
* **Services:**
  * **NotificationService:** An `NSObject` singleton conforming to `UNUserNotificationCenterDelegate`, initialized at the root `App` level. It is responsible for scheduling calendar-based local notifications and forcing iOS to present them even when the app is in the foreground.
  * **LocationService:** An `ObservableObject` built on `CLLocationManager` to actively track device GPS coordinates and embed them into the user's gameplay history.
* **Data Models:** `GameSession` instances conform to `Codable`, `Identifiable`, and `Hashable`, allowing them to be effortlessly persisted, iterated in dynamic lists, and safely used as selection bindings in interactive Maps.

## Known Limitations
* **Storage Scalability:** Currently, `GameSessionManager` stores all sessions in a single array encoded into `UserDefaults`. If a user plays thousands of times, this could eventually lead to memory overhead and slower file parsing. A future architectural migration to `SwiftData` or `CoreData` is highly recommended for scalable database querying.
* **Location Initialization:** Because `LocationService` retrieves location dynamically, if the system cannot acquire a GPS fix fast enough before the game ends, the session might default to hardcoded fallback coordinates.
* **Simulator Quirkiness:** Local notifications and dynamic location spoofing can sometimes behave unreliably when running strictly in the Xcode Simulator due to Apple's underlying simulator daemons, though they function flawlessly on physical iPhones.

## Reflection
Building TapFrenzy involved navigating several distinct challenges associated with modern iOS development. One major hurdle was untangling the default aggregation behavior of `SwiftUI.Charts` when handling multiple data points recorded on the exact same day; manually formatting the `BarMark` properties to map distinct indices rather than dates dramatically improved chart accuracy.

Additionally, integrating iOS 17's new declarative `MapKit` selection syntax required updating legacy model structures to ensure strict `Hashable` conformance. Furthermore, managing the lifecycle of local notifications reinforced the importance of early object initialization; tracking down a bug where foreground notifications were failing to render proved to be an issue of singleton lazily-loading, which was efficiently resolved by explicitly initializing the `NotificationService` in the root `App` struct. Overall, this project demonstrates how clean, reactive, and feature-rich applications can be rapidly developed utilizing pure SwiftUI without relying on any massive third-party dependencies.
