import SwiftUI
import MapKit

struct MeetupPickerView: View {
    let offer: Offer
    @StateObject private var vm = MeetupViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map(position: $camera, selection: $vm.selectedPlace) {
                    UserAnnotation()
                    ForEach(vm.nearbyPlaces) { place in
                        Marker(place.name, systemImage: "mappin", coordinate: place.coordinate)
                            .tag(place)
                    }
                }
                .frame(height: 280)

                List {
                    Section {
                        Text("\(offer.buyerName) · \(offer.listingTitle)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Section("Nearby spots") {
                        if vm.isLoadingPlaces {
                            HStack {
                                ProgressView()
                                Text("Finding spots near you…")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        ForEach(vm.nearbyPlaces) { place in
                            placeRow(place)
                        }
                    }

                    Section {
                        DatePicker("When", selection: $vm.meetupTime, in: Date()...)
                    }

                    Section {
                        Button {
                            Task {
                                await vm.confirmMeetup(offer: offer)
                                if vm.transaction != nil { dismiss() }
                            }
                        } label: {
                            Text("Confirm Meetup")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(vm.selectedPlace == nil)
                    }
                }
            }
            .appBackground()
            .navigationTitle("Choose a Meetup Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: vm.selectedPlace) { _, place in
                if let place {
                    withAnimation {
                        camera = .region(MKCoordinateRegion(center: place.coordinate, latitudinalMeters: 800, longitudinalMeters: 800))
                    }
                }
            }
            .task {
                await vm.requestLocation()
                await vm.loadNearbyPlaces()
            }
            .errorAlert($vm.errorMessage)
        }
    }

    private func placeRow(_ place: MeetupLocation) -> some View {
        Button {
            vm.selectedPlace = place
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(place.name)
                        .foregroundStyle(.primary)
                    if let distance = vm.distanceText(to: place) {
                        Text(distance)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if vm.selectedPlace == place {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
        }
    }
}
