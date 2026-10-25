import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var offers = OfferViewModel()

    var body: some View {
        if auth.currentUser == nil {
            LoginView()
        } else {
            TabView {
                MarketplaceView()
                    .tabItem { Label("Market", systemImage: "house") }
                OffersView()
                    .tabItem { Label("Offers", systemImage: "arrow.left.arrow.right") }
                CreateListingView()
                    .tabItem { Label("Sell", systemImage: "plus.circle") }
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
            }
            .environmentObject(offers)
        }
    }
}
