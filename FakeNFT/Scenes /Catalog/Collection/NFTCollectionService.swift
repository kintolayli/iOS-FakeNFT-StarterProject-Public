//
//  NFTCollectionService.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 05.01.2025.
//

import Foundation


final class NFTCollectionService {
    static var shared = NFTCollectionService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {}
    
    func fetchNFT(ids: [UUID], _ completion: @escaping (Result<[NftModel], Error>) -> Void) {
        var fetchedNFT: [NftModel] = []
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        
        for id in ids {
            dispatchGroup.enter()
            
            guard let request = try? makeFetchNFTRequest(id: id) else {
                errors.append(NetworkClientError.invalidRequest)
                dispatchGroup.leave()
                continue
            }
            
            let task = urlSession.objectTask(for: request) { (result: Result<NftModel, Error>) in
                
                switch result {
                case .success(let nft):
                    fetchedNFT.append(nft)
                case .failure(let error):
                    errors.append(error)
                }
                dispatchGroup.leave()
            }
            self.task = task
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(fetchedNFT))
            } else {
                guard let error = errors.first else { return }
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private methods

private extension NFTCollectionService {
    
    func makeFetchNFTRequest(id: UUID) throws -> URLRequest? {
        
        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }
        
        let lowercasedID = "\(id)".lowercased()
        
        urlComponents.path = "/api/v1/nft/\(lowercasedID)"
        
        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        return request
    }
}
