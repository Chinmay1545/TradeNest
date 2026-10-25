import SwiftUI

struct OffersView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var offers: OfferViewModel
    @State private var showSent = false
    @State private var acceptedOffer: Offer?

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Offers", selection: $showSent) {
                    Text("Received").tag(false)
                    Text("Sent").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    if showSent {
                        ForEach(offers.sent) { offer in
                            sentRow(offer)
                        }
                    } else {
                        ForEach(offers.received) { offer in
                            receivedRow(offer)
                        }
                    }
                }
            }
            .navigationTitle("Offers")
            .task { await offers.loadOffers(userId: auth.currentUser?.id ?? "") }
            .sheet(item: $acceptedOffer) { offer in
                MeetupPickerView(offer: offer)
            }
        }
    }

    private func receivedRow(_ offer: Offer) -> some View {
        VStack(alignment: .leading) {
            Text("\(offer.buyerName) for \(offer.listingTitle)")
            Text("\(offer.type.rawValue): \(offer.cashAmount, format: .currency(code: "USD"))")
            Text(offer.status.rawValue)
                .foregroundStyle(.secondary)
            if offer.status == .pending {
                HStack {
                    Button("Reject") {
                        Task { await offers.reject(offer) }
                    }
                    Button("Accept") {
                        Task {
                            await offers.accept(offer)
                            acceptedOffer = offer
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func sentRow(_ offer: Offer) -> some View {
        VStack(alignment: .leading) {
            Text(offer.listingTitle)
            Text("\(offer.type.rawValue): \(offer.cashAmount, format: .currency(code: "USD"))")
            Text(offer.status.rawValue)
                .foregroundStyle(.secondary)
            if offer.status == .pending {
                Button("Withdraw") {
                    Task { await offers.withdraw(offer) }
                }
                .buttonStyle(.bordered)
            }
            if offer.status == .accepted {
                NavigationLink("View Meetup") {
                    MeetupDetailView(offer: offer)
                }
            }
        }
    }
}
