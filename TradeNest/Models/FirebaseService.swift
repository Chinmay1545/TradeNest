import Foundation

enum ServiceError: LocalizedError {
    case invalidEmail

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please use your .edu email."
        }
    }
}

struct FirebaseService {
    func signIn(email: String, password: String) async throws -> User {
        guard email.hasSuffix(".edu") else { throw ServiceError.invalidEmail }
        return SampleData.user
    }

    func signUp(name: String, email: String, password: String) async throws -> User {
        guard email.hasSuffix(".edu") else { throw ServiceError.invalidEmail }
        return User(id: UUID().uuidString, name: name, email: email, major: "", campus: "Tempe")
    }

    func fetchListings() async throws -> [Listing] {
        SampleData.listings
    }

    func saveListing(_ listing: Listing) async throws {
    }

    func deleteListing(id: String) async throws {
    }

    func fetchOffers(userId: String) async throws -> [Offer] {
        SampleData.offers
    }

    func saveOffer(_ offer: Offer) async throws {
    }

    func deleteOffer(id: String) async throws {
    }

    func fetchTransactions(userId: String) async throws -> [Transaction] {
        SampleData.transactions
    }

    func fetchTransaction(offerId: String) async throws -> Transaction? {
        SampleData.transactions.first { $0.offerId == offerId }
    }

    func saveTransaction(_ transaction: Transaction) async throws {
    }
}
