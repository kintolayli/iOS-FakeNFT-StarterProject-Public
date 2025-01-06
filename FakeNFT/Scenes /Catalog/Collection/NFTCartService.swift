//
//  NFTCartService.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 06.01.2025.
//

import Foundation


final class NFTCartService {
    static var shared = NFTCartService()

    private var fetchedNFTsInCart: Set<UUID> = []
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()

    private init() {}

    func fetchNFTInCart(profileId: Int, _ completion: @escaping (Result<[UUID], Error>) -> Void) {
        guard let request = try? makefetchNFTInCartRequest(id: profileId) else {
            completion(.failure(NetworkClientError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OrderModel, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let cart):
                self.fetchedNFTsInCart = Set(cart.nfts)
                completion(.success(Array(self.fetchedNFTsInCart)))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    func sendNFTToCart(profileId: Int, nftId: UUID, _ completion: @escaping (Result<String, Error>) -> Void) {
        if fetchedNFTsInCart.contains(nftId) {
            fetchedNFTsInCart.remove(nftId)
        } else {
            fetchedNFTsInCart.insert(nftId)
        }

        guard let request = try? makeSendNFTToCart(profileId: profileId, nftId: Array(fetchedNFTsInCart)) else {
            completion(.failure(NetworkClientError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) { (result: Result<OrderModel, Error>) in

            switch result {
            case .success:
                completion(.success("NFT отправлен в корзину"))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }
}

// MARK: - Private methods

private extension NFTCartService {
    func makefetchNFTInCartRequest(id: Int) throws -> URLRequest? {

        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }

        urlComponents.path = "/api/v1/orders/\(id)"

        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        return request
    }

    func makeSendNFTToCart(profileId: Int, nftId: [UUID]) throws -> URLRequest? {
        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }
        urlComponents.path = "/api/v1/orders/\(profileId)"

        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.put.rawValue
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        if fetchedNFTsInCart.isEmpty {
            let bodyString = "nfts=null"
            request.httpBody = bodyString.data(using: .utf8)
        } else {
            let likesNftIdStrings = fetchedNFTsInCart.map { $0.uuidString.lowercased() }
            let bodyString = "nfts=\(likesNftIdStrings.joined(separator: ","))"
            request.httpBody = bodyString.data(using: .utf8)
        }

        return request
    }
}
