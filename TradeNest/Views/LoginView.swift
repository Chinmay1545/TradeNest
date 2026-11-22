import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var isLoggingIn = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Logo and tagline
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 20))
            Text("TradeNest")
                .font(.largeTitle)
                .bold()
            Text("Buy, sell, or trade what you no longer need with students on your campus.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)

            TextField("School email (.edu)", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))

            if !auth.errorMessage.isEmpty {
                Text(auth.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    isLoggingIn = true
                    await auth.login(email: email, password: password)
                    isLoggingIn = false
                }
            } label: {
                if isLoggingIn {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Log In")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.isEmpty || password.isEmpty || isLoggingIn)

            Button("Create an Account") {
                auth.errorMessage = ""
                showSignUp = true
            }

            Spacer()

            Label("Only .edu emails can sign up, so every buyer and seller is a student.", systemImage: "checkmark.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(Color("AppBackground"))
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}
