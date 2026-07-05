import SwiftUI

struct SettingsTab: View {
    @AppStorage("reminderTime") var reminderTime: Date = Date()
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                DatePicker("Daily Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { oldValue, newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        NotificationService.shared.scheduleDailyReminder(at: components.hour!, minute: components.minute!)
                    }
            }
        }
        .onAppear {
            NotificationService.shared.requestPermission()
        }
        .navigationTitle("Settings")
    }
}
