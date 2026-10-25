import Foundation
import Combine

@MainActor
final class MarketplaceViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var searchText = ""
    @Published var category: Category?

    private let service = FirebaseService()

    var filteredListings: [Listing] {
        listings.filter { listing in
            (category == nil || listing.category == category) &&
            (searchText.isEmpty || listing.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    func loadListings() async {
        listings = (try? await service.fetchListings()) ?? []
    }
}
