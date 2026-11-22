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
                    Text("Received (\(offers.pendingReceivedCount))").tag(false)
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
                .overlay { emptyState }
                .refreshable { await loadOffers() }
            }
            .navigationTitle("Offers")
            .task { await loadOffers() }
            .errorAlert($offers.errorMessage)
            .sheet(item: $acceptedOffer) { offer in
                MeetupPickerView(offer: offer)
            }
        }
    }

    private func loadOffers() async {
        if let user = auth.currentUser {
            await offers.loadOffers(userId: user.id)
        }
    }

    /// Spinner on first load, or a friendly message when the chosen tab has no offers.
    @ViewBuilder
    private var emptyState: some View {
        let list = showSent ? offers.sent : offers.received
        if offers.isLoading && list.isEmpty {
            ProgressView("Loading offers…")
        } else if list.isEmpty && showSent {
            ContentUnavailableView(
                "No Sent Offers",
                systemImage: "paperplane",
                description: Text("Find something in the Market and make an offer.")
            )
        } else if list.isEmpty {
            ContentUnavailableView(
                "No Offers Yet",
                systemImage: "tray",
                description: Text("Offers on your listings will show up here.")
            )
        }
    }

    private func receivedRow(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                InitialsAvatar(name: offer.buyerName)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(offer.buyerName) for \(offer.listingTitle)")
                        .font(.subheadline)
                        .bold()
                    offerTypeLabel(offer)
                    if !offer.message.isEmpty {
                        Text("\"\(offer.message)\"")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                StatusBadge(status: offer.status)
            }
            if offer.status == .pending {
                HStack {
                    Button("Reject") {
                        Task { await offers.reject(offer) }
                    }
                    .buttonStyle(.bordered)
                    Button("Accept") {
                        Task {
                            await offers.accept(offer)
                            // Only open the meetup picker if the accept actually saved.
                            if offers.received.first(where: { $0.id == offer.id })?.status == .accepted {
                                acceptedOffer = offer
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            // Lets the seller schedule (or view) the meetup any time after accepting.
            if offer.status == .accepted {
                NavigationLink("Meetup") {
                    MeetupDetailView(offer: offer)
                }
            }
        }
        .padding(.vertical, 4)
        .swipeActions {
            if offer.status == .pending {
                Button("Reject", role: .destructive) {
                    Task { await offers.reject(offer) }
                }
            }
        }
    }

    private func sentRow(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.listingTitle)
                        .font(.subheadline)
                        .bold()
                    offerTypeLabel(offer)
                }
                Spacer()
                StatusBadge(status: offer.status)
            }
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
        .padding(.vertical, 4)
        .swipeActions {
            if offer.status == .pending {
                Button("Withdraw", role: .destructive) {
                    Task { await offers.withdraw(offer) }
                }
            }
        }
    }

    /// Icon for cash vs trade, plus the summary text from the ViewModel.
    private func offerTypeLabel(_ offer: Offer) -> some View {
        Label(offers.offerSummary(offer), systemImage: offer.type == .cash ? "dollarsign.circle" : "arrow.left.arrow.right.circle")
            .font(.subheadline)
    }
}
