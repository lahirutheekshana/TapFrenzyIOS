import SwiftUI

@main
struct TapFrenzyIOSApp: App {
    @AppStorage("themeMode") private var themeMode: ThemeMode = .dark
    @AppStorage("accentColor") private var accentColor: AppAccentColor = .blue
    
    init() {
        _ = NotificationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(themeMode.colorScheme)
                .tint(accentColor.color)
        }
    }
}

