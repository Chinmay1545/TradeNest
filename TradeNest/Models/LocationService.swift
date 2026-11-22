import Foundation
import CoreLocation
import MapKit

enum LocationError: LocalizedError {
    case denied
    case unavailable
    case noPlacesFound

    var errorDescription: String? {
        switch self {
        case .denied: return "Location access is off. Turn it on in Settings > TradeNest > Location to find meetup spots near you."
        case .unavailable: return "Couldn't get your location. Try again in a moment."
        case .noPlacesFound: return "No public meetup spots found near you."
        }
    }
}

/// Gets the user's real GPS location (CLLocationManager) and searches for real places near it (MKLocalSearch).
/// It's a class because CLLocationManager reports results through a delegate.
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    /// Holds the waiting `currentLocation()` call until the delegate gets an answer.
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - Current location

    /// Asks for permission if needed, then returns one location fix.
    func currentLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus
        if status == .denied || status == .restricted {
            throw LocationError.denied
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            if status == .notDetermined {
                // The answer arrives in locationManagerDidChangeAuthorization below.
                manager.requestWhenInUseAuthorization()
            } else {
                manager.requestLocation()
            }
        }
    }

    /// Finishes the waiting call exactly once.
    private func finish(with result: Result<CLLocationCoordinate2D, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }

    // MARK: - CLLocationManagerDelegate
    // CoreLocation calls these from outside our main actor, so they are `nonisolated`
    // and hop back to the main actor before touching our properties.

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            guard self.continuation != nil else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            case .denied, .restricted:
                self.finish(with: .failure(LocationError.denied))
            default:
                break // still waiting for the user to answer the prompt
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        Task { @MainActor in
            self.finish(with: .success(coordinate))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.finish(with: .failure(LocationError.unavailable))
        }
    }

    // MARK: - Nearby meetup spots

    /// Searches Apple Maps for public places around `center` and turns them into MeetupLocations.
    func searchNearby(near center: CLLocationCoordinate2D) async throws -> [MeetupLocation] {
        let queries = ["library", "cafe", "student union"]
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 3000, longitudinalMeters: 3000)
        var places: [MeetupLocation] = []

        for query in queries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region

            let response: MKLocalSearch.Response
            do {
                response = try await MKLocalSearch(request: request).start()
            } catch {
                continue // no results for this one query; the other queries can still find places
            }

            for item in response.mapItems {
                guard let name = item.name else { continue }
                let coordinate = item.placemark.coordinate
                let place = MeetupLocation(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude)
                if !places.contains(where: { $0.name == place.name }) {
                    places.append(place)
                }
            }
        }

        if places.isEmpty {
            throw LocationError.noPlacesFound
        }

        // Closest spots first, and keep the list short.
        let here = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let sorted = places.sorted {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: here) <
            CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: here)
        }
        return Array(sorted.prefix(10))
    }
}
