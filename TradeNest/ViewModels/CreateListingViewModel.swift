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
    @Published var coverURL: String?
    /// True after a successful ISBN lookup, so the view can show "Filled from Open Library".
    @Published var bookWasFilled = false
    @Published var isLookingUp = false
    @Published var isPosting = false
    @Published var errorMessage: String?

    private let service = FirebaseService()
    private let bookService = BookAPIService()

    func lookupISBN() async {
        isLookingUp = true
        do {
            let book = try await bookService.fetchBook(isbn: isbn)
            title = book.title
            author = book.author
            coverURL = book.coverURL
            category = .textbooks
            bookWasFilled = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        isLookingUp = false
    }

    func postListing(sellerId: String, sellerName: String) async -> Bool {
        guard !title.isEmpty, price > 0 else {
            errorMessage = "Add a title and a price greater than $0."
            return false
        }
        let listing = Listing(id: UUID().uuidString, sellerId: sellerId, sellerName: sellerName, title: title, description: description, category: category, condition: condition, price: price, isbn: isbn.isEmpty ? nil : isbn, author: author.isEmpty ? nil : author, imageURL: coverURL, openToTrades: openToTrades, status: .available)
        isPosting = true
        defer { isPosting = false }
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
        coverURL = nil
        bookWasFilled = false
        errorMessage = nil
    }
}
