import Foundation
import Combine

@MainActor
final class OfferViewModel: ObservableObject {
    @Published var received: [Offer] = []
    @Published var sent: [Offer] = []

    private let service = FirebaseService()

    func loadOffers(userId: String) async {
        let offers = (try? await service.fetchOffers(userId: userId)) ?? []
        received = offers.filter { $0.sellerId == userId }
        sent = offers.filter { $0.buyerId == userId }
    }

    func makeOffer(listing: Listing, type: OfferType, cash: Double, tradeItem: Listing?, message: String, buyer: User) async {
        let offer = Offer(id: UUID().uuidString, listingId: listing.id, listingTitle: listing.title, buyerId: buyer.id, buyerName: buyer.name, sellerId: listing.sellerId, type: type, cashAmount: cash, tradeListingId: tradeItem?.id, message: message, status: .pending)
        try? await service.saveOffer(offer)
        sent.append(offer)
    }

    func accept(_ offer: Offer) async {
        await setStatus(.accepted, for: offer)
    }

    func reject(_ offer: Offer) async {
        await setStatus(.rejected, for: offer)
    }

    func withdraw(_ offer: Offer) async {
        try? await service.deleteOffer(id: offer.id)
        sent.removeAll { $0.id == offer.id }
    }

    private func setStatus(_ status: OfferStatus, for offer: Offer) async {
        guard let index = received.firstIndex(where: { $0.id == offer.id }) else { return }
        received[index].status = status
        try? await service.saveOffer(received[index])
    }
}
