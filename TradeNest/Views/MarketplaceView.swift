import SwiftUI

struct MarketplaceView: View {
    @StateObject private var vm = MarketplaceViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Category", selection: $vm.category) {
                    Text("All").tag(Category?.none)
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(Category?.some(category))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List(vm.filteredListings) { listing in
                    NavigationLink {
                        ItemDetailView(listing: listing)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(listing.title)
                                Text(listing.sellerName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(listing.price, format: .currency(code: "USD"))
                        }
                    }
                }
            }
            .navigationTitle("Marketplace")
            .searchable(text: $vm.searchText)
            .task { await vm.loadListings() }
        }
    }
}
