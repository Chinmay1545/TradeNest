import Foundation

enum TransactionStatus: String, Codable {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case canceled = "Canceled"
}

struct Transaction: Identifiable, Codable {
    var id: String
    var offerId: String
    var buyerId: String
    var sellerId: String
    var itemTitle: String
    var meetup: MeetupLocation
    var meetupTime: Date
    var status: TransactionStatus
}
