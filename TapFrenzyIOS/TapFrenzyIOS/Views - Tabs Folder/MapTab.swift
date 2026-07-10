import SwiftUI
import MapKit

struct MapTab: View {
    @ObservedObject var manager = GameSessionManager.shared
    @State private var showDetailsPane = false
    
    // Calculate the common coordinate using the last session, or default to Colombo
    var commonCoordinate: CLLocationCoordinate2D {
        if let lastSession = manager.sessions.last {
            return CLLocationCoordinate2D(latitude: lastSession.latitude, longitude: lastSession.longitude)
        }
        return CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
    }
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )
    
    var body: some View {
        NavigationStack {
            Map(position: $position) {
                if !manager.sessions.isEmpty {
                    Annotation("All Games", coordinate: commonCoordinate) {
                        Button(action: {
                            showDetailsPane = true
                        }) {
                            VStack {
                                Text("\(manager.sessions.count)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(radius: 3)
                                
                                Text("Total Games")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Game Map")
            .onAppear {
                _ = LocationService.shared
                if !manager.sessions.isEmpty {
                    position = .region(MKCoordinateRegion(center: commonCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
                }
            }
            .sheet(isPresented: $showDetailsPane) {
                GameDetailsPane(sessions: manager.sessions)
            }
        }
    }
}

struct GameDetailsPane: View {
    var sessions: [GameSession]
    
    var body: some View {
        NavigationStack {
            List {
                if sessions.isEmpty {
                    Text("No games played yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(SessionGameMode.allCases, id: \.self) { mode in
                        let modeSessions = sessions.filter { $0.mode == mode }
                        
                        if !modeSessions.isEmpty {
                            DisclosureGroup {
                                ForEach(modeSessions) { session in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Score: \(session.score)")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "calendar")
                                                    .foregroundColor(.secondary)
                                                Text(session.timestamp, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Image(systemName: "clock")
                                                    .foregroundColor(.secondary)
                                                    .padding(.leading, 4)
                                                Text(session.timestamp, style: .time)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                }
                            } label: {
                                HStack {
                                    Text(mode.rawValue)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(modeSessions.count) games")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    MapTab()
}
