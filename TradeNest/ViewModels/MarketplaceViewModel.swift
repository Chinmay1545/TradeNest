import Foundation
import Combine

@MainActor
final class MarketplaceViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var searchText = ""
    @Published var category: Category?
    /// When true, only show listings whose seller accepts trade offers.
    @Published var tradesOnly = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = FirebaseService()

    var filteredListings: [Listing] {
        listings.filter { listing in
            (category == nil || listing.category == category) &&
            (!tradesOnly || listing.openToTrades) &&
            (searchText.isEmpty || listing.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    func loadListings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            listings = try await service.fetchAvailableListings()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
