import SwiftUI
import FirebaseCore

@main struct MyApp: App {
    @StateObject private var auth: AuthViewModel

    init() {
        // Firebase must be configured before any service touches Auth or Firestore.
        FirebaseApp.configure()
        _auth = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}
