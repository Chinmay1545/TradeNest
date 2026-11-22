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
                        ListingRow(listing: listing)
                    }
                }
                .overlay {
                    if vm.isLoading && vm.listings.isEmpty {
                        ProgressView("Loading listings…")
                    } else if vm.filteredListings.isEmpty && !vm.searchText.isEmpty {
                        ContentUnavailableView.search(text: vm.searchText)
                    } else if vm.filteredListings.isEmpty {
                        ContentUnavailableView(
                            "No Listings",
                            systemImage: "tray",
                            description: Text("Nothing for sale here yet. Post something on the Sell tab!")
                        )
                    }
                }
                .refreshable { await vm.loadListings() }
            }
            .navigationTitle("Marketplace")
            .searchable(text: $vm.searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $vm.tradesOnly) {
                        Label("Trades only", systemImage: "arrow.left.arrow.right")
                    }
                    .toggleStyle(.button)
                }
            }
            .task { await vm.loadListings() }
            .errorAlert($vm.errorMessage)
        }
    }
}
