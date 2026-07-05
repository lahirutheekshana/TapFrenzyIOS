import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 1. Home Tab (Games Menu)
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
            
            // 2. Stats Tab
            StatsTab(sessions: []) // දැනට දත්ත නැත්නම් හිස් array එකක් දාන්න,
                                   // නැත්නම් ඔයාගේ සැබෑ sessions array එක මෙතනට දෙන්න.
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            // 3. Map Tab
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            // 4. Settings Tab
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
}
