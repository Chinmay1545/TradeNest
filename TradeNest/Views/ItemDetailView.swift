import SwiftUI

struct ItemDetailView: View {
    let listing: Listing
    @EnvironmentObject var auth: AuthViewModel
    @State private var showOffer = false

    /// Buyers can only make offers on someone else's listing that is still Available.
    private var canMakeOffer: Bool {
        listing.sellerId != auth.currentUser?.id && listing.status == .available
    }

    var body: some View {
        List {
            // Big cover picture
            Section {
                HStack {
                    Spacer()
                    ListingImage(listing: listing, width: 160, height: 220)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

            Section {
                Text(listing.title)
                    .font(.title2)
                    .bold()
                HStack {
                    TagView(text: listing.condition.rawValue)
                    TagView(text: listing.category.rawValue)
                    if listing.openToTrades {
                        TagView(text: "Open to trades", color: .accentColor)
                    }
                    if listing.status != .available {
                        TagView(text: listing.status.rawValue, color: .orange)
                    }
                }
                if !listing.description.isEmpty {
                    Text(listing.description)
                }
            }

            if listing.author != nil || listing.isbn != nil {
                Section("Book Info") {
                    if let author = listing.author {
                        LabeledContent("Author", value: author)
                    }
                    if let isbn = listing.isbn {
                        LabeledContent("ISBN", value: isbn)
                    }
                }
            }

            Section("Seller") {
                HStack(spacing: 12) {
                    InitialsAvatar(name: listing.sellerName)
                    Text(listing.sellerName)
                        .font(.headline)
                }
            }

            Section {
                LabeledContent("Asking", value: listing.price, format: .currency(code: "USD"))
                    .font(.headline)
                if canMakeOffer {
                    Button {
                        showOffer = true
                    } label: {
                        Text("Make Offer")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showOffer) {
            MakeOfferView(listing: listing)
        }
    }
}
