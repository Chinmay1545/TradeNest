import Foundation

enum Category: String, CaseIterable, Codable {
    case textbooks = "Textbooks"
    case electronics = "Electronics"
    case dorm = "Dorm"
}

enum Condition: String, CaseIterable, Codable {
    case new = "New"
    case likeNew = "Like New"
    case good = "Good"
    case fair = "Fair"
}

enum ListingStatus: String, Codable {
    case available = "Available"
    case pending = "Pending"
    case sold = "Sold"
}

struct Listing: Identifiable, Codable {
    var id: String
    var sellerId: String
    var sellerName: String
    var title: String
    var description: String
    var category: Category
    var condition: Condition
    var price: Double
    var isbn: String?
    var author: String?
    var imageURL: String?
    var openToTrades: Bool
    var status: ListingStatus
}
