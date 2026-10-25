import Foundation
import CoreLocation
import Combine

@MainActor
final class MeetupViewModel: ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var nearbyPlaces: [MeetupLocation] = []
    @Published var selectedPlace: MeetupLocation?
    @Published var meetupTime = Date()
    @Published var transaction: Transaction?

    private let service = FirebaseService()
    private let locationService = LocationService()

    func requestLocation() async {
        userLocation = try? await locationService.currentLocation()
    }

    func loadNearbyPlaces() async {
        nearbyPlaces = (try? await locationService.searchNearby(query: "campus")) ?? []
    }

    func loadMeetup(for offer: Offer) async {
        transaction = try? await service.fetchTransaction(offerId: offer.id)
    }

    func confirmMeetup(offer: Offer) async {
        guard let place = selectedPlace else { return }
        let newTransaction = Transaction(id: UUID().uuidString, offerId: offer.id, buyerId: offer.buyerId, sellerId: offer.sellerId, itemTitle: offer.listingTitle, meetup: place, meetupTime: meetupTime, status: .scheduled)
        try? await service.saveTransaction(newTransaction)
        transaction = newTransaction
    }

    func completeTransaction() async {
        guard var current = transaction else { return }
        current.status = .completed
        try? await service.saveTransaction(current)
        transaction = current
    }
}
