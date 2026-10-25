import Foundation
import CoreLocation

struct LocationService {
    func currentLocation() async throws -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 33.4184, longitude: -111.9350)
    }

    func searchNearby(query: String) async throws -> [MeetupLocation] {
        SampleData.meetupSpots
    }
}
