import Foundation

enum SampleData {
    static let user = User(id: "u1", name: "Alex Chen", email: "alex@asu.edu", major: "Computer Science", campus: "Tempe")

    static let memorialUnion = MeetupLocation(name: "Memorial Union", latitude: 33.4176, longitude: -111.9348)
    static let haydenLibrary = MeetupLocation(name: "Hayden Library", latitude: 33.4192, longitude: -111.9343)
    static let sdfc = MeetupLocation(name: "Sun Devil Fitness Complex", latitude: 33.4245, longitude: -111.9325)

    static let meetupSpots = [memorialUnion, haydenLibrary, sdfc]

    static let listings = [
        Listing(id: "l1", sellerId: "u2", sellerName: "Maya R.", title: "Calculus: Early Transcendentals", description: "Used for MAT 265 and 266.", category: .textbooks, condition: .likeNew, price: 45, isbn: "978-1285741550", author: "James Stewart", imageURL: nil, openToTrades: true, status: .available),
        Listing(id: "l2", sellerId: "u3", sellerName: "Jordan K.", title: "TI-84 Plus CE Calculator", description: "Works perfectly.", category: .electronics, condition: .good, price: 70, isbn: nil, author: nil, imageURL: nil, openToTrades: false, status: .available),
        Listing(id: "l3", sellerId: "u4", sellerName: "Priya S.", title: "Sony WH-1000XM4 Headphones", description: "Comes with case.", category: .electronics, condition: .likeNew, price: 120, isbn: nil, author: nil, imageURL: nil, openToTrades: true, status: .available),
        Listing(id: "l4", sellerId: "u5", sellerName: "Ethan L.", title: "Mini Fridge, 3.1 cu ft", description: "Clean and cold.", category: .dorm, condition: .good, price: 60, isbn: nil, author: nil, imageURL: nil, openToTrades: false, status: .available),
        Listing(id: "l5", sellerId: "u1", sellerName: "Alex C.", title: "Introduction to Algorithms", description: "4th edition.", category: .textbooks, condition: .likeNew, price: 50, isbn: "978-0262046305", author: "Cormen, Leiserson, Rivest, Stein", imageURL: nil, openToTrades: true, status: .available),
        Listing(id: "l6", sellerId: "u1", sellerName: "Alex C.", title: "TI-84 Plus CE", description: "Barely used.", category: .electronics, condition: .likeNew, price: 70, isbn: nil, author: nil, imageURL: nil, openToTrades: false, status: .available)
    ]

    static let offers = [
        Offer(id: "o1", listingId: "l6", listingTitle: "TI-84 Plus CE", buyerId: "u3", buyerName: "Jordan K.", sellerId: "u1", type: .cash, cashAmount: 40, tradeListingId: nil, message: "Can pick it up tomorrow afternoon.", status: .pending),
        Offer(id: "o2", listingId: "l5", listingTitle: "Introduction to Algorithms", buyerId: "u4", buyerName: "Priya S.", sellerId: "u1", type: .trade, cashAmount: 10, tradeListingId: "l7", message: "Chemistry book plus $10?", status: .pending),
        Offer(id: "o3", listingId: "l3", listingTitle: "Sony WH-1000XM4 Headphones", buyerId: "u1", buyerName: "Alex C.", sellerId: "u4", type: .cash, cashAmount: 110, tradeListingId: nil, message: "", status: .accepted),
        Offer(id: "o4", listingId: "l1", listingTitle: "Calculus: Early Transcendentals", buyerId: "u1", buyerName: "Alex C.", sellerId: "u2", type: .trade, cashAmount: 0, tradeListingId: "l6", message: "Trade for my TI-84?", status: .pending)
    ]

    static let transactions = [
        Transaction(id: "t1", offerId: "o3", buyerId: "u1", sellerId: "u4", itemTitle: "Sony WH-1000XM4 Headphones", meetup: memorialUnion, meetupTime: Date().addingTimeInterval(86400 * 3), status: .scheduled),
        Transaction(id: "t2", offerId: "o0", buyerId: "u5", sellerId: "u1", itemTitle: "Mini Fridge", meetup: haydenLibrary, meetupTime: Date().addingTimeInterval(-86400 * 13), status: .completed)
    ]
}
