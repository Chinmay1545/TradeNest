import Foundation

enum OfferType: String, Codable {
    case cash = "Cash"
    case trade = "Trade"
}

enum OfferStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case rejected = "Rejected"
}

struct Offer: Identifiable, Codable {
    var id: String
    var listingId: String
    var listingTitle: String
    var buyerId: String
    var buyerName: String
    var sellerId: String
    var type: OfferType
    var cashAmount: Double
    var tradeListingId: String?
    var message: String
    var status: OfferStatus
}
