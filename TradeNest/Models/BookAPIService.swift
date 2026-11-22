import Foundation

struct BookInfo {
    var title: String
    var author: String
    var coverURL: String?
}

enum BookAPIError: LocalizedError {
    case invalidISBN
    case notFound
    case badResponse

    var errorDescription: String? {
        switch self {
        case .invalidISBN: return "Enter a 10 or 13 digit ISBN."
        case .notFound: return "No book found for that ISBN."
        case .badResponse: return "The book service didn't respond. Try again."
        }
    }
}

// Open Library response: {"ISBN:9780262046305": {"title": "...", "authors": [{"name": "..."}], "cover": {"medium": "https://..."}}}
private struct OpenLibraryBook: Codable {
    var title: String
    var authors: [OpenLibraryAuthor]?
    var cover: OpenLibraryCover?
}

private struct OpenLibraryAuthor: Codable {
    var name: String
}

private struct OpenLibraryCover: Codable {
    var small: String?
    var medium: String?
    var large: String?
}

struct BookAPIService {
    func fetchBook(isbn: String) async throws -> BookInfo {
        // Our sample ISBNs have hyphens/spaces, so keep only digits (and X, used in old ISBN-10s).
        let cleanISBN = isbn.uppercased().filter { $0.isNumber || $0 == "X" }
        guard cleanISBN.count == 10 || cleanISBN.count == 13 else {
            throw BookAPIError.invalidISBN
        }

        let address = "https://openlibrary.org/api/books?bibkeys=ISBN:\(cleanISBN)&format=json&jscmd=data"
        guard let url = URL(string: address) else { throw BookAPIError.invalidISBN }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw BookAPIError.badResponse
        }

        // The response is a dictionary keyed by "ISBN:<isbn>". An unknown ISBN returns {}.
        let results = try JSONDecoder().decode([String: OpenLibraryBook].self, from: data)
        guard let book = results["ISBN:\(cleanISBN)"] else {
            throw BookAPIError.notFound
        }

        let authorNames = (book.authors ?? []).map { $0.name }
        return BookInfo(
            title: book.title,
            author: authorNames.joined(separator: ", "),
            coverURL: book.cover?.medium ?? book.cover?.large ?? book.cover?.small
        )
    }
}
