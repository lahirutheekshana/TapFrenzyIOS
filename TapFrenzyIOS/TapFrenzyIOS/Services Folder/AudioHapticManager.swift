import Foundation
import AudioToolbox
import UIKit

class AudioHapticManager {
    static let shared = AudioHapticManager()
    
    private init() {}
    
    // MARK: - Haptics
    
    func playTapHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playNotificationHaptic(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    // MARK: - Sounds
    
    func playTapSound() {
        // 1104 is a standard system click/tock sound
        AudioServicesPlaySystemSound(1104)
    }
    
    func playSuccessSound() {
        // 1322 is a generic success/chime sound
        AudioServicesPlaySystemSound(1322)
    }
    
    func playGameOverSound() {
        // 1025 is a nice alert/notification sound
        AudioServicesPlaySystemSound(1025)
    }
}
