import SwiftUI
import MapKit

struct MapTab: View {
    // Save කරපු sessions ටික මෙතනින් Load කරගන්න
    let sessions = GameSessionManager.shared.loadSessions()
    
    // සිතියමේ පේන ප්‍රදේශය (ආරම්භක ස්ථානය කොළඹට දාමු)
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    
    var body: some View {
        Map(position: $position) {
            // හැම session එකකටම අදාළව Marker එකක් හදනවා
            ForEach(sessions) { session in
                Annotation("Score: \(session.score)",
                           coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
        }
        .navigationTitle("Game Map")
    }
}
