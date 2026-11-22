import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var major = ""
    @State private var campus = "Tempe"
    @State private var isSubmitting = false

    private let campuses = ["Tempe", "Downtown Phoenix", "Polytechnic", "West Valley"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Full name", text: $name)
                        .textContentType(.name)
                    TextField("School email (.edu)", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                    SecureField("Password (6+ characters)", text: $password)
                        .textContentType(.newPassword)
                }
                Section("School") {
                    TextField("Major", text: $major)
                    Picker("Campus", selection: $campus) {
                        ForEach(campuses, id: \.self) { Text($0) }
                    }
                }
                if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .foregroundStyle(.red)
                }
                Button("Create Account") {
                    Task {
                        isSubmitting = true
                        await auth.register(name: name, email: email, password: password, major: major, campus: campus)
                        isSubmitting = false
                        if auth.currentUser != nil { dismiss() }
                    }
                }
                .disabled(name.isEmpty || email.isEmpty || password.isEmpty || isSubmitting)
            }
            .navigationTitle("Create Account")
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
