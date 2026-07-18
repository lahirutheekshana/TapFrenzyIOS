import SwiftUI

struct HomeTab: View {
    @AppStorage("username") var username: String = "Player"
    @AppStorage("userAvatar") var userAvatar: String = "person.crop.circle.fill"
    @State private var showingProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [Color(.systemBackground),
                        Color(.systemGroupedBackground)]),
                        startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    VStack(spacing: 8) {
                        Text("HI \(username.uppercased())!")
                            .font(.system(
                                size: 38,
                                weight: .black,
                                design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Text("iOS Game Dashboard")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 30)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            
                            // Game 1
                            NavigationLink(destination: TapFrenzyView()) {
                                GameCardView(
                                    title: "Tap Frenzy",
                                    subtitle: "Speed Tap Challenge",
                                    icon: "hand.tap.fill",
                                    color: .orange,
                                    badge: "Task 1")
                            }
                            
                            // Game 2
                            NavigationLink(destination: LightItUpView()) {
                                GameCardView(
                                    title: "Light It Up",
                                    subtitle: "Memory & Logic Puzzle",
                                    icon: "lightbulb.fill",
                                    color: .blue,
                                    badge: "Task 2")
                            }
                            
                            // Game 3
                            NavigationLink(destination: QuizRushView()) {
                                GameCardView(
                                    title: "Quiz Rush",
                                    subtitle: "Trivia Time Attack",
                                    icon: "timer",
                                    color: .purple,
                                    badge: "Task 3")
                            }
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingProfile = true
                        }) {
                            Image(systemName: userAvatar)
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                                .shadow(color: .blue.opacity(0.4), radius: 5, x: 0, y: 2)
                        }
                        
                        NavigationLink(destination: HighScoreHistoryView()) {
                            Image(systemName: "trophy.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.4), radius: 5, x: 0, y: 2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }
}


struct GameCardView: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let badge: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color.gradient)
                    .frame(width: 65, height: 65)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.15))
                        .cornerRadius(8)
                }
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.leading, 5)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    MainTabView()
}

