import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 16) {
            Text("TradeNest")
                .font(.largeTitle)
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            if !auth.errorMessage.isEmpty {
                Text(auth.errorMessage)
                    .foregroundStyle(.red)
            }
            Button("Log In") {
                Task { await auth.login(email: email, password: password) }
            }
            .buttonStyle(.borderedProminent)
            Button("Create an Account") {
                auth.errorMessage = ""
                showSignUp = true
            }
        }
        .padding()
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}
