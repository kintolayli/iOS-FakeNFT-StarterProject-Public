//
//  NFTLikeService.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 06.01.2025.
//

import Foundation


final class NFTLikeService {
    static var shared = NFTLikeService()
    
    private var fetchedLikes: Set<UUID> = []
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {}
    
    func fetchLikes(profileId: Int, _ completion: @escaping (Result<[UUID], Error>) -> Void) {
        guard let request = try? makeFetchLikeRequest(profileId: profileId) else {
            completion(.failure(NetworkClientError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileModel, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.fetchedLikes = Set(profile.likes)
                completion(.success(Array(self.fetchedLikes)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func sendLike(profileId: Int, nftId: UUID, _ completion: @escaping (Result<String, Error>) -> Void) {
        if fetchedLikes.contains(nftId) {
            fetchedLikes.remove(nftId)
        } else {
            fetchedLikes.insert(nftId)
        }
        
        guard let request = try? makeSendLikeRequest(profileId: profileId, likesNftId: Array(fetchedLikes)) else {
            completion(.failure(NetworkClientError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileModel, Error>) in
            
            switch result {
            case .success:
                completion(.success("Лайк обновлен"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}

// MARK: - Private methods

private extension NFTLikeService {
    func makeFetchLikeRequest(profileId: Int) throws -> URLRequest? {
        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }
        
        urlComponents.path = "/api/v1/profile/\(profileId)"
        
        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        return request
    }
    
    func makeSendLikeRequest(profileId: Int, likesNftId: [UUID]) throws -> URLRequest? {
        guard var urlComponents = URLComponents(string: RequestConstants.baseURL) else {
            throw NetworkClientError.invalidBaseUrl
        }
        urlComponents.path = "/api/v1/profile/\(profileId)"
        
        guard let url = urlComponents.url else {
            throw NetworkClientError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.put.rawValue
        request.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        if likesNftId.isEmpty {
            let bodyString = "likes=null"
            request.httpBody = bodyString.data(using: .utf8)
        } else {
            let likesNftIdStrings = likesNftId.map { $0.uuidString.lowercased() }
            let bodyString = "likes=\(likesNftIdStrings.joined(separator: ","))"
            request.httpBody = bodyString.data(using: .utf8)
        }
        
        return request
    }
}
