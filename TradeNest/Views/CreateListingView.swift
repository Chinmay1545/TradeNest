import SwiftUI

struct CreateListingView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = CreateListingViewModel()
    @State private var posted = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Textbook Lookup") {
                    TextField("ISBN", text: $vm.isbn)
                    Button("Look Up") {
                        Task { await vm.lookupISBN() }
                    }
                }
                Section("Details") {
                    TextField("Title", text: $vm.title)
                    TextField("Author", text: $vm.author)
                    TextField("Description", text: $vm.description)
                    Picker("Category", selection: $vm.category) {
                        ForEach(Category.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Picker("Condition", selection: $vm.condition) {
                        ForEach(Condition.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    TextField("Asking price", value: $vm.price, format: .number)
                        .keyboardType(.decimalPad)
                    Toggle("Open to trade offers", isOn: $vm.openToTrades)
                }
                Button("Post Listing") {
                    guard let user = auth.currentUser else { return }
                    Task { posted = await vm.postListing(sellerId: user.id, sellerName: user.name) }
                }
            }
            .navigationTitle("New Listing")
            .alert("Listing posted", isPresented: $posted) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
