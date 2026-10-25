import Foundation

struct BookInfo {
    var title: String
    var author: String
    var coverURL: String?
}

struct BookAPIService {
    func fetchBook(isbn: String) async throws -> BookInfo {
        BookInfo(title: "Introduction to Algorithms, 4th Ed.", author: "Cormen, Leiserson, Rivest, Stein", coverURL: nil)
    }
}
