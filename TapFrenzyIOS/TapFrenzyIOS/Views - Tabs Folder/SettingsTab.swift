import SwiftUI

struct SettingsTab: View {
    
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @AppStorage("reminderTime") var reminderTime: Date = Date()
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            if newValue {
                                NotificationService.shared.requestPermission()
                                scheduleNotification()
                            } else {
                                NotificationService.shared.cancelDailyReminder()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Daily Challenge Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { oldValue, newValue in
                                scheduleNotification()
                            }
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive, action: {
                        showingResetConfirmation = true
                    }) {
                        HStack {
                            Text("Reset All Statistics")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Statistics", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    GameSessionManager.shared.resetSessions()
                }
            } message: {
                Text("Are you sure you want to permanently delete all your game statistics? This action cannot be undone.")
            }
        }
    }
    
    private func scheduleNotification() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        if let hour = components.hour, let minute = components.minute {
            NotificationService.shared.scheduleDailyReminder(at: hour, minute: minute)
        }
    }
}

#Preview {
    SettingsTab()
}
