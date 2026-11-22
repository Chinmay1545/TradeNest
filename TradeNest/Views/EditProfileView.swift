import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var user: User

    init(user: User) {
        _user = State(initialValue: user)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $user.name)
                TextField("Major", text: $user.major)
                TextField("Campus", text: $user.campus)
                LabeledContent("Email", value: user.email)
                if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await auth.updateProfile(user)
                            if auth.errorMessage.isEmpty { dismiss() }
                        }
                    }
                    .disabled(user.name.isEmpty)
                }
            }
        }
    }
}
