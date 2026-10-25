import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let user = vm.user {
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
                Button("Log Out") { auth.logout() }
            }
            .task {
                if let user = auth.currentUser {
                    await vm.loadProfile(user: user)
                }
            }
        }
    }
}
