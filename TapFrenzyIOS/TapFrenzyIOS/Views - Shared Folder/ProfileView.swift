import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("username") var username: String = "Player"
    @AppStorage("userAvatar") var userAvatar: String = "person.crop.circle.fill"
    @State private var editedName: String = ""
    @State private var selectedAvatar: String = "person.crop.circle.fill"
    
    let avatars = ["person.crop.circle.fill", "person.circle.fill", "face.smiling.fill", "gamecontroller.fill", "star.circle.fill", "heart.circle.fill", "sparkles"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account Details")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        TextField("Enter your name", text: $editedName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Avatar")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(avatars, id: \.self) { avatar in
                                Image(systemName: avatar)
                                    .font(.system(size: 35))
                                    .foregroundColor(selectedAvatar == avatar ? .blue : .gray)
                                    .scaleEffect(selectedAvatar == avatar ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedAvatar)
                                    .onTapGesture {
                                        selectedAvatar = avatar
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 5)
                    }
                }
            }
            .navigationTitle("User Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        username = editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Player" : editedName
                        userAvatar = selectedAvatar
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                editedName = username
                selectedAvatar = userAvatar
            }
        }
    }
}

#Preview {
    ProfileView()
}
