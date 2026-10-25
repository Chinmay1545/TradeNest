import SwiftUI

struct MakeOfferView: View {
    let listing: Listing
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var offers: OfferViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var type: OfferType = .cash
    @State private var cash: Double = 0
    @State private var message = ""

    var body: some View {
        NavigationStack {
            Form {
                Text(listing.title)
                Picker("Offer Type", selection: $type) {
                    Text("Cash Offer").tag(OfferType.cash)
                    Text("Trade Offer").tag(OfferType.trade)
                }
                .pickerStyle(.segmented)
                if type == .trade {
                    Text("Choose one of your items (coming soon)")
                        .foregroundStyle(.secondary)
                }
                TextField("Amount", value: $cash, format: .number)
                    .keyboardType(.decimalPad)
                TextField("Message", text: $message)
                Button("Send Offer") {
                    guard let user = auth.currentUser else { return }
                    Task {
                        await offers.makeOffer(listing: listing, type: type, cash: cash, tradeItem: nil, message: message, buyer: user)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Make an Offer")
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
