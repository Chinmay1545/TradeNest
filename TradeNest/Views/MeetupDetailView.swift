import SwiftUI
import MapKit

struct MeetupDetailView: View {
    let offer: Offer
    @StateObject private var vm = MeetupViewModel()

    var body: some View {
        VStack {
            if let transaction = vm.transaction {
                Map {
                    Marker(transaction.meetup.name, coordinate: transaction.meetup.coordinate)
                }
                .frame(height: 250)

                List {
                    LabeledContent("Place", value: transaction.meetup.name)
                    LabeledContent("Date", value: transaction.meetupTime.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Item", value: transaction.itemTitle)
                    LabeledContent("Status", value: transaction.status.rawValue)
                    if transaction.status == .scheduled {
                        Button("Mark as Completed") {
                            Task { await vm.completeTransaction() }
                        }
                    }
                }
            } else {
                Text("Waiting for the seller to pick a meetup spot")
            }
        }
        .navigationTitle("Meetup")
        .task { await vm.loadMeetup(for: offer) }
    }
}
