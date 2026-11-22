import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var myListings: [Listing] = []
    @Published var history: [Transaction] = []
    @Published var errorMessage: String?

    private let service = FirebaseService()

    func loadProfile(user: User) async {
        do {
            myListings = try await service.fetchListings(sellerId: user.id)
            history = try await service.fetchTransactions(userId: user.id)
                .sorted { $0.meetupTime > $1.meetupTime }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteListing(_ listing: Listing) async {
        do {
            try await service.deleteListing(id: listing.id)
            myListings.removeAll { $0.id == listing.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
