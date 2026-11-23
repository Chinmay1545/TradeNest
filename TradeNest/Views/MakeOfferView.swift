import SwiftUI

struct MakeOfferView: View {
    let listing: Listing
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var offers: OfferViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var type: OfferType = .cash
    @State private var cash: Double = 0
    @State private var message = ""
    @State private var tradeItem: Listing?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(listing.title)
                        .font(.headline)
                    Text("Asking \(listing.price, format: .currency(code: "USD")) · \(listing.sellerName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if listing.openToTrades {
                    Picker("Offer Type", selection: $type) {
                        Text("Cash Offer").tag(OfferType.cash)
                        Text("Trade Offer").tag(OfferType.trade)
                    }
                    .pickerStyle(.segmented)
                }

                if type == .cash {
                    Section("Your offer") {
                        TextField("Amount", value: $cash, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    }
                } else {
                    Section("Offer one of your items") {
                        if offers.myTradeItems.isEmpty {
                            Text("You have no available listings to trade. Post one on the Sell tab first.")
                                .foregroundStyle(.secondary)
                        }
                        ForEach(offers.myTradeItems) { item in
                            tradeItemRow(item)
                        }
                    }
                    Section("Add cash (optional)") {
                        TextField("Amount", value: $cash, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Message") {
                    TextField("Add a note for the seller", text: $message, axis: .vertical)
                }

                // Shown in the form (not as an alert) because OffersView already shows
                // alerts for this same shared OfferViewModel.
                if let error = offers.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }

                Section {
                    Button {
                        guard let user = auth.currentUser else { return }
                        Task {
                            let sent = await offers.makeOffer(listing: listing, type: type, cash: cash, tradeItem: type == .trade ? tradeItem : nil, message: message, buyer: user)
                            if sent { dismiss() }
                        }
                    } label: {
                        if offers.isSending {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Send Offer")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(offers.isSending)
                }
            }
            .appBackground()
            .navigationTitle("Make an Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                if let user = auth.currentUser {
                    await offers.loadMyTradeItems(userId: user.id)
                }
            }
            .onAppear { offers.errorMessage = nil }
            .onDisappear { offers.errorMessage = nil }
        }
    }

    private func tradeItemRow(_ item: Listing) -> some View {
        Button {
            tradeItem = item
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .foregroundStyle(.primary)
                    Text("Listed at \(item.price, format: .currency(code: "USD"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if tradeItem?.id == item.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
        }
    }
}
