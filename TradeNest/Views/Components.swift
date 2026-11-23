import SwiftUI

extension View {
    func appBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
    }
}

struct TagView: View {
    let text: String
    var color: Color = .secondary

    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(color)
            .background(color.opacity(0.15), in: Capsule())
    }
}

struct StatusBadge: View {
    let status: OfferStatus

    var body: some View {
        switch status {
        case .pending: TagView(text: "Pending", color: .orange)
        case .accepted: TagView(text: "Accepted", color: .green)
        case .rejected: TagView(text: "Rejected", color: .gray)
        }
    }
}

struct InitialsAvatar: View {
    let name: String
    var size: CGFloat = 40

    private var initials: String {
        let words = name.split(separator: " ").prefix(2)
        return words.map { String($0.prefix(1)) }.joined().uppercased()
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Color.accentColor, in: Circle())
    }
}

struct ListingImage: View {
    let listing: Listing
    var width: CGFloat = 50
    var height: CGFloat = 64

    private var iconName: String {
        switch listing.category {
        case .textbooks: return "book.closed"
        case .electronics: return "laptopcomputer"
        case .dorm: return "lamp.desk"
        }
    }

    var body: some View {
        AsyncImage(url: URL(string: listing.imageURL ?? "")) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: iconName)
                .font(.system(size: width * 0.4))
                .foregroundStyle(.secondary)
        }
        .frame(width: width, height: height)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ListingRow: View {
    let listing: Listing

    var body: some View {
        HStack(spacing: 12) {
            ListingImage(listing: listing)
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(listing.sellerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    TagView(text: listing.condition.rawValue)
                    if listing.openToTrades {
                        TagView(text: "Open to trades", color: .accentColor)
                    }
                }
            }
            Spacer()
            Text(listing.price, format: .currency(code: "USD"))
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}
