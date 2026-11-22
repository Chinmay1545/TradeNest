import SwiftUI

struct CreateListingView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = CreateListingViewModel()
    @State private var posted = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Textbook Lookup") {
                    HStack {
                        TextField("ISBN", text: $vm.isbn)
                            .keyboardType(.numbersAndPunctuation)
                        if vm.isLookingUp {
                            ProgressView()
                        } else {
                            Button("Look Up") {
                                Task { await vm.lookupISBN() }
                            }
                            .disabled(vm.isbn.isEmpty)
                        }
                    }
                    if vm.bookWasFilled {
                        bookPreview
                    }
                }

                Section("Details") {
                    TextField("Title", text: $vm.title)
                    TextField("Author", text: $vm.author)
                    TextField("Description", text: $vm.description, axis: .vertical)
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

                // Its own section so the button sits fully above the tab bar.
                Section {
                    Button {
                        guard let user = auth.currentUser else { return }
                        Task { posted = await vm.postListing(sellerId: user.id, sellerName: user.name) }
                    } label: {
                        if vm.isPosting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Post Listing")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(vm.isPosting)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .appBackground()
            .navigationTitle("New Listing")
            .alert("Listing posted", isPresented: $posted) {
                Button("OK", role: .cancel) {}
            }
            .errorAlert($vm.errorMessage)
        }
    }

    /// Cover + title shown after a successful Open Library lookup.
    private var bookPreview: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: vm.coverURL ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "book.closed")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50, height: 70)

            VStack(alignment: .leading, spacing: 4) {
                Label("Filled from Open Library", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text(vm.title)
                    .font(.subheadline)
                    .bold()
                Text(vm.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
