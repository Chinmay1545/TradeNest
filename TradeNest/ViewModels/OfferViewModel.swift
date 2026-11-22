import Foundation
import Combine

@MainActor
final class OfferViewModel: ObservableObject {
    @Published var received: [Offer] = []
    @Published var sent: [Offer] = []
    /// The buyer's own Available listings, shown as choices for a trade offer.
    @Published var myTradeItems: [Listing] = []
    @Published var isSending = false
    @Published var errorMessage: String?

    private let service = FirebaseService()

    func loadOffers(userId: String) async {
        do {
            let offers = try await service.fetchOffers(userId: userId)
            received = offers.filter { $0.sellerId == userId }
            sent = offers.filter { $0.buyerId == userId }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Loads the buyer's own listings that are still Available, so they can offer one as a trade.
    func loadMyTradeItems(userId: String) async {
        do {
            let myListings = try await service.fetchListings(sellerId: userId)
            myTradeItems = myListings.filter { $0.status == .available }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Returns a message if the offer isn't valid, or nil if it's OK to send.
    func validateOffer(type: OfferType, cash: Double, tradeItem: Listing?) -> String? {
        if cash < 0 {
            return "The cash amount can't be negative."
        }
        if type == .cash && cash <= 0 {
            return "Enter a cash amount greater than $0."
        }
        if type == .trade && tradeItem == nil {
            return "Pick one of your items to trade."
        }
        return nil
    }

    /// Returns true if the offer was saved, so the view knows it can close.
    func makeOffer(listing: Listing, type: OfferType, cash: Double, tradeItem: Listing?, message: String, buyer: User) async -> Bool {
        if let problem = validateOffer(type: type, cash: cash, tradeItem: tradeItem) {
            errorMessage = problem
            return false
        }
        let offer = Offer(id: UUID().uuidString, listingId: listing.id, listingTitle: listing.title, buyerId: buyer.id, buyerName: buyer.name, sellerId: listing.sellerId, type: type, cashAmount: cash, tradeListingId: tradeItem?.id, message: message, status: .pending)
        isSending = true
        defer { isSending = false }
        do {
            try await service.saveOffer(offer)
            sent.append(offer)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Accepting also rejects the other pending offers on the same listing.
    func accept(_ offer: Offer) async {
        do {
            let rejectedIds = try await service.acceptOffer(offer)
            setLocalStatus(.accepted, for: [offer.id])
            setLocalStatus(.rejected, for: rejectedIds)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reject(_ offer: Offer) async {
        do {
            try await service.rejectOffer(id: offer.id)
            setLocalStatus(.rejected, for: [offer.id])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func withdraw(_ offer: Offer) async {
        do {
            try await service.deleteOffer(id: offer.id)
            sent.removeAll { $0.id == offer.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setLocalStatus(_ status: OfferStatus, for ids: [String]) {
        for index in received.indices where ids.contains(received[index].id) {
            received[index].status = status
        }
    }
}
