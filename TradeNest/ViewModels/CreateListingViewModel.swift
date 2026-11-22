import Foundation
import Combine

@MainActor
final class CreateListingViewModel: ObservableObject {
    @Published var isbn = ""
    @Published var title = ""
    @Published var author = ""
    @Published var description = ""
    @Published var category: Category = .textbooks
    @Published var condition: Condition = .likeNew
    @Published var price: Double = 0
    @Published var openToTrades = true
    @Published var errorMessage: String?

    private let service = FirebaseService()
    private let bookService = BookAPIService()

    func lookupISBN() async {
        guard let book = try? await bookService.fetchBook(isbn: isbn) else { return }
        title = book.title
        author = book.author
    }

    func postListing(sellerId: String, sellerName: String) async -> Bool {
        guard !title.isEmpty, price > 0 else {
            errorMessage = "Add a title and a price greater than $0."
            return false
        }
        let listing = Listing(id: UUID().uuidString, sellerId: sellerId, sellerName: sellerName, title: title, description: description, category: category, condition: condition, price: price, isbn: isbn.isEmpty ? nil : isbn, author: author.isEmpty ? nil : author, imageURL: nil, openToTrades: openToTrades, status: .available)
        do {
            try await service.saveListing(listing)
            reset()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func reset() {
        isbn = ""
        title = ""
        author = ""
        description = ""
        category = .textbooks
        condition = .likeNew
        price = 0
        openToTrades = true
        errorMessage = nil
    }
}
