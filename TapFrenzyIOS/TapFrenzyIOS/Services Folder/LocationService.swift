import Foundation
import CoreLocation
import Combine // මේක අනිවාර්යයෙන්ම import කරන්න

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    // @Published පාවිච්චි කරන නිසා ObservableObject එක හරියට වැඩ කරයි
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // දත්ත UI එකට යවන්න main thread එක භාවිතා කරන්න
        DispatchQueue.main.async {
            self.currentLocation = locations.last
        }
    }
}
