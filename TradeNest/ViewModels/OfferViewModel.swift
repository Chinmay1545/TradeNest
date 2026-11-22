import Foundation
import Combine

@MainActor
final class OfferViewModel: ObservableObject {
    @Published var received: [Offer] = []
    @Published var sent: [Offer] = []
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

    func makeOffer(listing: Listing, type: OfferType, cash: Double, tradeItem: Listing?, message: String, buyer: User) async {
        let offer = Offer(id: UUID().uuidString, listingId: listing.id, listingTitle: listing.title, buyerId: buyer.id, buyerName: buyer.name, sellerId: listing.sellerId, type: type, cashAmount: cash, tradeListingId: tradeItem?.id, message: message, status: .pending)
        do {
            try await service.saveOffer(offer)
            sent.append(offer)
        } catch {
            errorMessage = error.localizedDescription
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
