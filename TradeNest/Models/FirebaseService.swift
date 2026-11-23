import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ServiceError: LocalizedError {
    case invalidEmail
    case missingFields
    case notSignedIn
    case listingUnavailable
    case tradeItemUnavailable
    case wrongLogin
    case emailTaken
    case weakPassword
    case noInternet

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please use your .edu email."
        case .missingFields: return "Please fill in all required fields."
        case .notSignedIn: return "You are not signed in."
        case .listingUnavailable: return "This item is no longer available."
        case .tradeItemUnavailable: return "The item offered in this trade is no longer available."
        case .wrongLogin: return "Wrong email or password."
        case .emailTaken: return "An account with this email already exists. Try logging in."
        case .weakPassword: return "Password must be at least 6 characters."
        case .noInternet: return "No internet connection. Check your connection and try again."
        }
    }
}

/// Wraps Firebase Auth and Firestore. Each model is stored in its own top-level
/// collection, keyed by the model's `id`, so documents decode straight back into the structs.
struct FirebaseService {
    private var db: Firestore { Firestore.firestore() }
    private var users: CollectionReference { db.collection("users") }
    private var listings: CollectionReference { db.collection("listings") }
    private var offers: CollectionReference { db.collection("offers") }
    private var transactions: CollectionReference { db.collection("transactions") }

    // MARK: - Auth

    func signIn(email: String, password: String) async throws -> User {
        let email = email.trimmingCharacters(in: .whitespaces)
        guard email.lowercased().hasSuffix(".edu") else { throw ServiceError.invalidEmail }
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return try await fetchUser(id: result.user.uid)
        } catch {
            throw friendlyAuthError(error)
        }
    }

    func signUp(name: String, email: String, password: String, major: String, campus: String) async throws -> User {
        let email = email.trimmingCharacters(in: .whitespaces)
        guard email.lowercased().hasSuffix(".edu") else { throw ServiceError.invalidEmail }
        guard !name.isEmpty else { throw ServiceError.missingFields }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(id: result.user.uid, name: name, email: email, major: major, campus: campus)
            try await saveUser(user)
            return user
        } catch {
            throw friendlyAuthError(error)
        }
    }

    /// Turns Firebase's technical login errors into messages a student understands.
    private func friendlyAuthError(_ error: Error) -> Error {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .wrongPassword, .invalidCredential, .userNotFound:
            return ServiceError.wrongLogin
        case .invalidEmail:
            return ServiceError.invalidEmail
        case .emailAlreadyInUse:
            return ServiceError.emailTaken
        case .weakPassword:
            return ServiceError.weakPassword
        case .networkError:
            return ServiceError.noInternet
        default:
            return error
        }
    }

    /// Returns the profile for the user Firebase remembers from a previous launch, if any.
    func restoreSession() async throws -> User? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return try await fetchUser(id: uid)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Users

    func fetchUser(id: String) async throws -> User {
        try await users.document(id).getDocument().data(as: User.self)
    }

    func saveUser(_ user: User) async throws {
        try await users.document(user.id).setData(Firestore.Encoder().encode(user))
    }

    // MARK: - Listings

    /// Listings that can still receive offers.
    func fetchAvailableListings() async throws -> [Listing] {
        let snapshot = try await listings
            .whereField("status", isEqualTo: ListingStatus.available.rawValue)
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: Listing.self) }
    }

    func fetchListings(sellerId: String) async throws -> [Listing] {
        let snapshot = try await listings.whereField("sellerId", isEqualTo: sellerId).getDocuments()
        return try snapshot.documents.map { try $0.data(as: Listing.self) }
    }

    func saveListing(_ listing: Listing) async throws {
        try await listings.document(listing.id).setData(Firestore.Encoder().encode(listing))
    }

    func deleteListing(id: String) async throws {
        try await listings.document(id).delete()
    }

    // MARK: - Offers

    /// Every offer the user sent or received.
    func fetchOffers(userId: String) async throws -> [Offer] {
        async let sent = offers.whereField("buyerId", isEqualTo: userId).getDocuments()
        async let received = offers.whereField("sellerId", isEqualTo: userId).getDocuments()
        let documents = try await sent.documents + received.documents
        return try documents.map { try $0.data(as: Offer.self) }
    }

    func saveOffer(_ offer: Offer) async throws {
        try await offers.document(offer.id).setData(Firestore.Encoder().encode(offer))
    }

    func deleteOffer(id: String) async throws {
        try await offers.document(id).delete()
    }

    func rejectOffer(id: String) async throws {
        try await offers.document(id).updateData(["status": OfferStatus.rejected.rawValue])
    }

    /// Accepts one offer and, in a single batch, marks its listing Pending and rejects
    /// every other pending offer on that listing. Returns the ids of the rejected offers.
    func acceptOffer(_ offer: Offer) async throws -> [String] {
        let listing = try await fetchListing(id: offer.listingId)
        if listing?.status != .available {
            throw ServiceError.listingUnavailable
        }

        // In a trade, the buyer's item must still be available too.
        if let tradeId = offer.tradeListingId {
            let tradeItem = try await fetchListing(id: tradeId)
            if tradeItem?.status != .available {
                throw ServiceError.tradeItemUnavailable
            }
        }

        let others = try await offers.whereField("listingId", isEqualTo: offer.listingId).getDocuments()
            .documents
            .map { try $0.data(as: Offer.self) }
            .filter { $0.id != offer.id && $0.status == .pending }

        let batch = db.batch()
        batch.updateData(["status": OfferStatus.accepted.rawValue], forDocument: offers.document(offer.id))
        batch.updateData(["status": ListingStatus.pending.rawValue], forDocument: listings.document(offer.listingId))
        if let tradeId = offer.tradeListingId {
            batch.updateData(["status": ListingStatus.pending.rawValue], forDocument: listings.document(tradeId))
        }
        for other in others {
            batch.updateData(["status": OfferStatus.rejected.rawValue], forDocument: offers.document(other.id))
        }
        try await batch.commit()
        return others.map(\.id)
    }

    // MARK: - Transactions

    /// Every meetup the user is part of, as buyer or seller.
    func fetchTransactions(userId: String) async throws -> [Transaction] {
        async let bought = transactions.whereField("buyerId", isEqualTo: userId).getDocuments()
        async let sold = transactions.whereField("sellerId", isEqualTo: userId).getDocuments()
        let documents = try await bought.documents + sold.documents
        return try documents.map { try $0.data(as: Transaction.self) }
    }

    func fetchTransaction(offerId: String) async throws -> Transaction? {
        let snapshot = try await transactions.whereField("offerId", isEqualTo: offerId).limit(to: 1).getDocuments()
        return try snapshot.documents.first?.data(as: Transaction.self)
    }

    func saveTransaction(_ transaction: Transaction) async throws {
        try await transactions.document(transaction.id).setData(Firestore.Encoder().encode(transaction))
    }

    /// Marks the meetup completed and the listing sold together.
    /// In a trade, the buyer's traded item is marked sold too.
    func completeTransaction(_ transaction: Transaction) async throws {
        let offer = try await offers.document(transaction.offerId).getDocument().data(as: Offer.self)

        let batch = db.batch()
        batch.updateData(["status": TransactionStatus.completed.rawValue], forDocument: transactions.document(transaction.id))
        batch.updateData(["status": ListingStatus.sold.rawValue], forDocument: listings.document(transaction.listingId))
        if let tradeId = offer.tradeListingId {
            batch.updateData(["status": ListingStatus.sold.rawValue], forDocument: listings.document(tradeId))
        }
        try await batch.commit()
    }

    func fetchListing(id: String) async throws -> Listing? {
        let document = try await listings.document(id).getDocument()
        guard document.exists else { return nil }
        return try document.data(as: Listing.self)
    }
}
