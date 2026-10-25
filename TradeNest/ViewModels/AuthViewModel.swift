import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var errorMessage = ""

    private let service = FirebaseService()

    func login(email: String, password: String) async {
        do {
            currentUser = try await service.signIn(email: email, password: password)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(name: String, email: String, password: String) async {
        do {
            currentUser = try await service.signUp(name: name, email: email, password: password)
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        currentUser = nil
    }
}
