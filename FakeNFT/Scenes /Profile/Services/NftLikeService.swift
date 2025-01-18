//
//  NftLikeService.swift
//  FakeNFT
//
//  Created by  Admin on 26.12.2024.
//

import Foundation

protocol NftLikeService {
    var likedNftIds: [String] { get }

    func fetchUserLikes(completion: @escaping (Result<[String], Error>) -> Void)
    func fetchAllLikes(completion: @escaping (Result<[String], Error>) -> Void)
    func toggleLike(for nftId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func isLiked(nftId: String) -> Bool
}

final class NftLikeServiceImpl: NftLikeService {

    // MARK: - Private Properties

    private let repository: MyNftRepository
    private(set) var likedNftIds: [String] = []
    private var updatingLikes: Set<String> = []

    // MARK: - Init

    init(repository: MyNftRepository) {
        self.repository = repository
    }

    // MARK: - Public Methods

    func fetchUserLikes(completion: @escaping (Result<[String], Error>) -> Void) {
        repository.fetchUserLikes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let likedIds):
                    self?.likedNftIds = likedIds
                    completion(.success(likedIds))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchAllLikes(completion: @escaping (Result<[String], Error>) -> Void) {
        repository.fetchAllLikedNfts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let allLikedIds):
                    self?.likedNftIds = allLikedIds
                    completion(.success(allLikedIds))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func toggleLike(for nftId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !updatingLikes.contains(nftId) else { return }
        updatingLikes.insert(nftId)

        let isCurrentlyLiked = likedNftIds.contains(nftId)
        if isCurrentlyLiked {
            likedNftIds.removeAll { $0 == nftId }
        } else {
            likedNftIds.append(nftId)
        }

        repository.updateUserLikes(likedNftIds: likedNftIds) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.updatingLikes.remove(nftId)

                switch result {
                case .success:
                    NotificationCenter.default.post(
                        name: .nftLikeStatusChanged,
                        object: nil,
                        userInfo: ["nftId": nftId, "isLiked": !isCurrentlyLiked]
                    )
                    completion(.success(!isCurrentlyLiked))
                case .failure(let error):
                    if isCurrentlyLiked {
                        self.likedNftIds.append(nftId)
                    } else {
                        self.likedNftIds.removeAll { $0 == nftId }
                    }
                    completion(.failure(error))
                }
            }
        }
    }

    func isLiked(nftId: String) -> Bool {
        return likedNftIds.contains(nftId)
    }
}
