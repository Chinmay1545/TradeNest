import Foundation
import Combine

@MainActor
final class OfferViewModel: ObservableObject {
    @Published var received: [Offer] = []
    @Published var sent: [Offer] = []
    @Published var myTradeItems: [Listing] = []
    @Published var tradeItemTitles: [String: String] = [:]
    @Published var isSending = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = FirebaseService()

    func loadOffers(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let offers = try await service.fetchOffers(userId: userId)
            received = offers.filter { $0.sellerId == userId }
            sent = offers.filter { $0.buyerId == userId }
            errorMessage = nil
            await loadTradeItemTitles(for: offers)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Trade offers only store the item's id, so look up each item's name once.
    private func loadTradeItemTitles(for offers: [Offer]) async {
        for offer in offers {
            guard let itemId = offer.tradeListingId, tradeItemTitles[itemId] == nil else { continue }
            do {
                let item = try await service.fetchListing(id: itemId)
                tradeItemTitles[itemId] = item?.title ?? "Item no longer listed"
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    var pendingReceivedCount: Int {
        received.filter { $0.status == .pending }.count
    }

    func offerSummary(_ offer: Offer) -> String {
        let cash = offer.cashAmount.formatted(.currency(code: "USD"))
        if offer.type == .cash {
            return "Cash: \(cash)"
        }
        var text = "Trade: \(tradeItemTitles[offer.tradeListingId ?? ""] ?? "an item")"
        if offer.cashAmount > 0 {
            text += " + \(cash)"
        }
        return text
    }

    func loadMyTradeItems(userId: String) async {
        do {
            let myListings = try await service.fetchListings(sellerId: userId)
            myTradeItems = myListings.filter { $0.status == .available }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

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

    func makeOffer(listing: Listing, type: OfferType, cash: Double, tradeItem: Listing?, message: String, buyer: User) async -> Bool {
        if let problem = validateOffer(type: type, cash: cash, tradeItem: tradeItem) {
            errorMessage = problem
            return false
        }
        let offer = Offer(id: UUID().uuidString, listingId: listing.id, listingTitle: listing.title, buyerId: buyer.id, buyerName: buyer.name, sellerId: listing.sellerId, type: type, cashAmount: cash, tradeListingId: tradeItem?.id, message: message, status: .pending)
        isSending = true
        defer { isSending = false }
        do {
            // The listing may have been accepted by someone else since this screen opened.
            let current = try await service.fetchListing(id: listing.id)
            if current?.status != .available {
                errorMessage = "This item is no longer available."
                return false
            }
            try await service.saveOffer(offer)
            sent.append(offer)
            if let tradeItem {
                tradeItemTitles[tradeItem.id] = tradeItem.title
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

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
