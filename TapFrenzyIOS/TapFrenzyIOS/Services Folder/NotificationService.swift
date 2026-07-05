import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted.")
            }
        }
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // පරණ ඒවා අයින් කරන්න
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge!"
        content.body = "අද ගේම් එකක් play කරලා ඔයාගේ score එක වැඩි කරගන්න!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request)
    }
}
