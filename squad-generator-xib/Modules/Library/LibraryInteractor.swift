//
//  LibraryInteractor.swift
//  squad-generator-xib
//
//  Created by Adham Farid on 30/10/25.
//

import Foundation

// MARK: - Models

struct BookResponse: Codable {
    let data: BookData
}

struct BookData: Codable {
    let allBooks: PaginatedBooks
    let book: Book?     
}

struct PaginatedBooks: Codable {
    let page: Int
    let size: Int
    let totalElements: Int
    let items: [Book]
}

struct Book: Codable {
    let id: Int
    let title: String
    let year: Int
    let author: Author?
}

struct Author: Codable {
    let id: Int?
    let name: String
}

// MARK: - GraphQL payload

private struct GraphQLQuery: Codable {
    let query: String
}

// MARK: - Interactor

final class LibraryInteractor {
    private let endpoint = URL(string: "http://ec2-52-221-203-202.ap-southeast-1.compute.amazonaws.com:8080/graphql")!

    func fetchAllBooks(completion: @escaping (Result<[Book], Error>) -> Void) {
        let query = """
        query AllBooks {
            allBooks(page: 0, size: 5) {
                page
                size
                totalElements
                items {
                    id
                    title
                    year
                    author {
                        id
                        name
                    }
                }
            }
        }
        """

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(GraphQLQuery(query: query))

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let err = NSError(domain: "HTTPError", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
                completion(.failure(err)); return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1))); return
            }

            do {
                let decoded = try JSONDecoder().decode(BookResponse.self, from: data)
                completion(.success(decoded.data.allBooks.items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
