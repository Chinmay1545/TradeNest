import SwiftUI
import MapKit

struct MeetupDetailView: View {
    let offer: Offer
    @StateObject private var vm = MeetupViewModel()
    @State private var hasLoaded = false

    var body: some View {
        Group {
            if let transaction = vm.transaction {
                meetupInfo(transaction)
            } else if !hasLoaded {
                ProgressView()
            } else {
                ContentUnavailableView(
                    "No Meetup Yet",
                    systemImage: "mappin.slash",
                    description: Text("Waiting for the seller to pick a meetup spot.")
                )
            }
        }
        .navigationTitle("Meetup")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadMeetup(for: offer)
            hasLoaded = true
            if vm.transaction != nil {
                await vm.requestLocation() // only used for the distance and the blue dot
            }
        }
        .errorAlert($vm.errorMessage)
    }

    private func meetupInfo(_ transaction: Transaction) -> some View {
        VStack(spacing: 0) {
            // .automatic fits both the meetup pin and the user's position.
            Map(initialPosition: .automatic) {
                UserAnnotation()
                Marker(transaction.meetup.name, systemImage: "mappin", coordinate: transaction.meetup.coordinate)
            }
            .frame(height: 280)

            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.meetup.name)
                            .font(.title3)
                            .bold()
                        if let distance = vm.distanceText(to: transaction.meetup) {
                            Text(distance)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button {
                        vm.openDirections(to: transaction.meetup)
                    } label: {
                        Label("Directions", systemImage: "figure.walk")
                    }
                }

                Section {
                    LabeledContent("Date", value: transaction.meetupTime.formatted(date: .abbreviated, time: .omitted))
                    LabeledContent("Time", value: transaction.meetupTime.formatted(date: .omitted, time: .shortened))
                    LabeledContent("Item", value: transaction.itemTitle)
                    LabeledContent("Status", value: transaction.status.rawValue)
                }

                if transaction.status == .scheduled {
                    Section {
                        Button {
                            Task { await vm.completeTransaction() }
                        } label: {
                            Text("Mark as Completed")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}
