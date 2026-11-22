import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
final class MeetupViewModel: ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var nearbyPlaces: [MeetupLocation] = []
    @Published var selectedPlace: MeetupLocation?
    @Published var meetupTime = Date()
    @Published var transaction: Transaction?
    @Published var isLoadingPlaces = false
    @Published var errorMessage: String?

    private let service = FirebaseService()
    private let locationService = LocationService()

    // MARK: - Location (Workstream C)

    /// Gets the user's real GPS position. Shows a message if location access is denied.
    func requestLocation() async {
        do {
            userLocation = try await locationService.currentLocation()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Searches for real public places around the user. Needs `requestLocation()` to have succeeded first.
    func loadNearbyPlaces() async {
        guard let here = userLocation else { return }
        isLoadingPlaces = true
        do {
            nearbyPlaces = try await locationService.searchNearby(near: here)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingPlaces = false
    }

    /// e.g. "0.3 mi away", or nil until we know where the user is.
    func distanceText(to place: MeetupLocation) -> String? {
        guard let user = userLocation else { return nil }
        let here = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let there = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let miles = here.distance(from: there) / 1609.34
        return String(format: "%.1f mi away", miles)
    }

    /// Opens Apple Maps with walking directions to the meetup spot.
    func openDirections(to place: MeetupLocation) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }

    // MARK: - Firestore (Workstream A)

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
