//
//  MyNftRepository.swift
//  FakeNFT
//
//  Created by  Admin on 26.12.2024.
//

import Foundation

protocol MyNftRepository {
    func fetchAllNfts(
        nftIds: [String],
        sort: NftRequest.NftSort,
        completion: @escaping (Result<[NFT], Error>) -> Void
    )

    func fetchUserLikes(
        completion: @escaping (Result<[String], Error>) -> Void
    )

    func fetchAllLikedNfts(
        completion: @escaping (Result<[String], Error>) -> Void
    )

    func updateUserLikes(
        likedNftIds: [String],
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class MyNftRepositoryImpl: MyNftRepository {

    // MARK: - Private Properties

    private let nftService: MyNftService
    private let profileService: ProfileService

    // MARK: - Init

    init(nftService: MyNftService, profileService: ProfileService) {
        self.nftService = nftService
        self.profileService = profileService
    }

    // MARK: - Public Methods

    func fetchAllNfts(
        nftIds: [String],
        sort: NftRequest.NftSort,
        completion: @escaping (Result<[NFT], Error>) -> Void
    ) {
        nftService.loadAllNfts(ids: nftIds) { result in
            completion(result)
        }
    }

    func fetchUserLikes(
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        profileService.getProfile { result in
            switch result {
            case .success(let profile):
                completion(.success(profile.likes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchAllLikedNfts(
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        profileService.getProfile { result in
            switch result {
            case .success(let profile):
                completion(.success(profile.likes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateUserLikes(
        likedNftIds: [String],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        profileService.getProfile { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let profile):
                self.profileService.updateProfile(
                    name: profile.name,
                    avatar: profile.avatar,
                    description: profile.description,
                    website: profile.website,
                    likes: likedNftIds.isEmpty ? nil : likedNftIds
                ) { updateResult in
                    switch updateResult {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
