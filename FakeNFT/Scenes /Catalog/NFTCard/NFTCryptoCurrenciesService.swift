//
//  NFTCryptoCurrenciesService.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 14.01.2025.
//

import Foundation


final class NFTCryptoCurrenciesService {
    static var shared = NFTCryptoCurrenciesService()
    
    private var cryptoCurrencies: [CryptoCurrencyModel] = []
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {}
    
    func fetchCryptoCurrencies(_ completion: @escaping (Result<[CryptoCurrencyModel], Error>) -> Void) {
        guard let request = try? makeFetchCryptoCurrencies() else {
            completion(.failure(NetworkClientError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[CryptoCurrencyModel], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let currencies):
                self.cryptoCurrencies = currencies
                completion(.success(self.cryptoCurrencies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}

// MARK: - Private methods

private extension NFTCryptoCurrenciesService {
    func makeFetchCryptoCurrencies() throws -> URLRequest? {
        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }
        
        urlComponents.path = "/api/v1/currencies"
        
        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        return request
    }
}
