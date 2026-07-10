import SwiftUI

@main
struct TapFrenzyIOSApp: App {
    
    init() {
        _ = NotificationService.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

