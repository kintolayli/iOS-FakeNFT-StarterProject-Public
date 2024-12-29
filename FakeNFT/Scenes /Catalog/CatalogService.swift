//
//  CatalogService.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 24.12.2024.
//

import Foundation


final class CatalogService {

    static var shared = CatalogService()
    static let didChangeNotification = Notification.Name(rawValue: "CatalogServiceDidChange")

    private(set) var catalog: [NFTCollectionModel] = []
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()

    private init() {}

    func fetchCatalog(_ completion: @escaping (Result<[NFTCollectionModel], Error>) -> Void) {
        guard let request = try? makeCatalogRequest() else {
            completion(.failure(NetworkClientError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[NFTCollectionModel], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let response):
//                for element in response {
//                    self.catalog.append(element)
//                }
                self.catalog.append(contentsOf: response)
                completion(.success(self.catalog))

//                NotificationCenter.default.post(name: CatalogService.didChangeNotification, object: nil)

            case .failure(let error):
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }
}

// MARK: - Private methods

private extension CatalogService {

    func makeCatalogRequest() throws -> URLRequest? {

        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }

        urlComponents.path = "/api/v1/collections"

        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue

        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        return request
    }
}
