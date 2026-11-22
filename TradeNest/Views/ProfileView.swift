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
                        header(user)
                    }
                }

                if vm.isLoading && vm.myListings.isEmpty && vm.history.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                Section("My Listings") {
                    if vm.myListings.isEmpty && !vm.isLoading {
                        Text("You haven't listed anything yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(vm.myListings) { listing in
                        myListingRow(listing)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let listing = vm.myListings[index]
                            Task { await vm.deleteListing(listing) }
                        }
                    }
                }

                Section("Transaction History") {
                    if vm.history.isEmpty && !vm.isLoading {
                        Text("No meetups yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(vm.history) { transaction in
                        historyRow(transaction)
                    }
                }
            }
            .appBackground()
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
            .refreshable { await loadProfile() }
            .task { await loadProfile() }
            .errorAlert($vm.errorMessage)
        }
    }

    private func loadProfile() async {
        if let user = auth.currentUser {
            await vm.loadProfile(user: user)
        }
    }

    private func header(_ user: User) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                InitialsAvatar(name: user.name, size: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.title2)
                        .bold()
                    Text("\(user.major) · \(user.campus)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack {
                statBox(number: vm.activeCount, label: "Active")
                statBox(number: vm.soldCount, label: "Sold")
                statBox(number: vm.completedCount, label: "Completed")
            }
        }
        .padding(.vertical, 4)
    }

    private func statBox(number: Int, label: String) -> some View {
        VStack {
            Text("\(number)")
                .font(.title3)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func myListingRow(_ listing: Listing) -> some View {
        HStack(spacing: 12) {
            ListingImage(listing: listing, width: 40, height: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                Text(listing.price, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TagView(text: listing.status.rawValue, color: listing.status == .available ? .green : .orange)
        }
    }

    private func historyRow(_ transaction: Transaction) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.itemTitle)
                Text("\(transaction.meetup.name) · \(transaction.meetupTime.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                TagView(text: vm.role(in: transaction, userId: auth.currentUser?.id ?? ""), color: .accentColor)
                Text(transaction.status.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
