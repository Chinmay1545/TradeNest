import SwiftUI

struct ItemDetailView: View {
    let listing: Listing
    @EnvironmentObject var auth: AuthViewModel
    @State private var showOffer = false

    var body: some View {
        List {
            Text(listing.title)
                .font(.title2)
            Text(listing.description)
            LabeledContent("Price", value: listing.price, format: .currency(code: "USD"))
            LabeledContent("Condition", value: listing.condition.rawValue)
            LabeledContent("Seller", value: listing.sellerName)
            if let author = listing.author {
                LabeledContent("Author", value: author)
            }
            if let isbn = listing.isbn {
                LabeledContent("ISBN", value: isbn)
            }
            if listing.openToTrades {
                Text("Open to trades")
            }
            if listing.sellerId != auth.currentUser?.id {
                Button("Make Offer") { showOffer = true }
            }
        }
        .navigationTitle("Item Details")
        .sheet(isPresented: $showOffer) {
            MakeOfferView(listing: listing)
        }
    }
}
