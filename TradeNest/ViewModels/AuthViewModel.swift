import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var errorMessage = ""
    /// True while checking for a saved Firebase session at launch, so the login screen doesn't flash.
    @Published var isRestoringSession = true

    private let service = FirebaseService()

    func restoreSession() async {
        currentUser = try? await service.restoreSession()
        isRestoringSession = false
    }

    func login(email: String, password: String) async {
        do {
            currentUser = try await service.signIn(email: email, password: password)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(name: String, email: String, password: String, major: String, campus: String) async {
        do {
            currentUser = try await service.signUp(name: name, email: email, password: password, major: major, campus: campus)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateProfile(_ user: User) async {
        do {
            try await service.saveUser(user)
            currentUser = user
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        do {
            try service.signOut()
            currentUser = nil
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
