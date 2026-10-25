import SwiftUI
import MapKit

struct MeetupPickerView: View {
    let offer: Offer
    @StateObject private var vm = MeetupViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Map {
                    ForEach(vm.nearbyPlaces) { place in
                        Marker(place.name, coordinate: place.coordinate)
                    }
                }
                .frame(height: 250)

                List {
                    ForEach(vm.nearbyPlaces) { place in
                        Button {
                            vm.selectedPlace = place
                        } label: {
                            HStack {
                                Text(place.name)
                                Spacer()
                                if vm.selectedPlace == place {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    DatePicker("When", selection: $vm.meetupTime)
                    Button("Confirm Meetup") {
                        Task {
                            await vm.confirmMeetup(offer: offer)
                            dismiss()
                        }
                    }
                    .disabled(vm.selectedPlace == nil)
                }
            }
            .navigationTitle("Choose a Meetup Spot")
            .task {
                await vm.requestLocation()
                await vm.loadNearbyPlaces()
            }
        }
    }
}
