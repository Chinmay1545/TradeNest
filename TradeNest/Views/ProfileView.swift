import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = ProfileViewModel()
    @State private var editingUser: User?

    var body: some View {
        NavigationStack {
            List {
                if let user = auth.currentUser {
                    Section {
                        Text(user.name)
                            .font(.title2)
                        Text("\(user.major) · \(user.campus)")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("My Listings") {
                    ForEach(vm.myListings) { listing in
                        HStack {
                            Text(listing.title)
                            Spacer()
                            Text(listing.price, format: .currency(code: "USD"))
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let listing = vm.myListings[index]
                            Task { await vm.deleteListing(listing) }
                        }
                    }
                }
                Section("Transaction History") {
                    ForEach(vm.history) { transaction in
                        VStack(alignment: .leading) {
                            Text(transaction.itemTitle)
                            Text("\(transaction.meetup.name) · \(transaction.status.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Edit") { editingUser = auth.currentUser }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log Out") { auth.logout() }
                }
            }
            .sheet(item: $editingUser) { user in
                EditProfileView(user: user)
            }
            .task {
                if let user = auth.currentUser {
                    await vm.loadProfile(user: user)
                }
            }
        }
    }
}
