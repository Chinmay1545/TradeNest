import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var myListings: [Listing] = []
    @Published var history: [Transaction] = []

    private let service = FirebaseService()

    func loadProfile(user: User) async {
        self.user = user
        let listings = (try? await service.fetchListings()) ?? []
        myListings = listings.filter { $0.sellerId == user.id }
        history = (try? await service.fetchTransactions(userId: user.id)) ?? []
    }

    func updateProfile() async {
    }

    func deleteListing(_ listing: Listing) async {
        try? await service.deleteListing(id: listing.id)
        myListings.removeAll { $0.id == listing.id }
    }
}
