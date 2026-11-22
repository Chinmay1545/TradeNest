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
    @Published var errorMessage: String?

    private let service = FirebaseService()
    private let locationService = LocationService()

    func requestLocation() async {
        userLocation = try? await locationService.currentLocation()
    }

    func loadNearbyPlaces() async {
        nearbyPlaces = (try? await locationService.searchNearby(query: "campus")) ?? []
    }

    func loadMeetup(for offer: Offer) async {
        do {
            transaction = try await service.fetchTransaction(offerId: offer.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmMeetup(offer: Offer) async {
        guard let place = selectedPlace else { return }
        let newTransaction = Transaction(id: UUID().uuidString, offerId: offer.id, listingId: offer.listingId, buyerId: offer.buyerId, sellerId: offer.sellerId, itemTitle: offer.listingTitle, meetup: place, meetupTime: meetupTime, status: .scheduled)
        do {
            try await service.saveTransaction(newTransaction)
            transaction = newTransaction
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Completing the meetup also marks the listing as sold.
    func completeTransaction() async {
        guard var current = transaction else { return }
        do {
            try await service.completeTransaction(current)
            current.status = .completed
            transaction = current
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
