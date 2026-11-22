import Foundation

// Placeholder meetup spots until LocationService uses MKLocalSearch (Workstream C).
enum SampleData {
    static let memorialUnion = MeetupLocation(name: "Memorial Union", latitude: 33.4176, longitude: -111.9348)
    static let haydenLibrary = MeetupLocation(name: "Hayden Library", latitude: 33.4192, longitude: -111.9343)
    static let sdfc = MeetupLocation(name: "Sun Devil Fitness Complex", latitude: 33.4245, longitude: -111.9325)

    static let meetupSpots = [memorialUnion, haydenLibrary, sdfc]
}
