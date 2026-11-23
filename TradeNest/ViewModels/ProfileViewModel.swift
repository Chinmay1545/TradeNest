import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var myListings: [Listing] = []
    @Published var history: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = FirebaseService()

    func loadProfile(user: User) async {
        isLoading = true
        defer { isLoading = false }
        do {
            myListings = try await service.fetchListings(sellerId: user.id)
            history = try await service.fetchTransactions(userId: user.id)
                .sorted { $0.meetupTime > $1.meetupTime }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var activeCount: Int {
        myListings.filter { $0.status == .available }.count
    }

    var soldCount: Int {
        myListings.filter { $0.status == .sold }.count
    }

    var completedCount: Int {
        history.filter { $0.status == .completed }.count
    }

    func role(in transaction: Transaction, userId: String) -> String {
        transaction.buyerId == userId ? "Bought" : "Sold"
    }

    func deleteListing(_ listing: Listing) async {
        if listing.status != .available {
            errorMessage = "You can't delete a listing that's part of a trade."
            return
        }
        do {
            try await service.deleteListing(id: listing.id)
            myListings.removeAll { $0.id == listing.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
