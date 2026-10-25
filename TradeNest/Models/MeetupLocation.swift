import Foundation
import CoreLocation

struct MeetupLocation: Identifiable, Codable, Hashable {
    var name: String
    var latitude: Double
    var longitude: Double

    var id: String { name }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
