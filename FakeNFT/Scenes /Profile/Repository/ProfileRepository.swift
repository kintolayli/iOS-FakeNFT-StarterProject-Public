//
//  ProfileRepository.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

protocol ProfileRepository {
    func fetchUserProfile(completion: @escaping ProfileCompletion)
    func updateProfile(
        name: String?,
        avatar: String?,
        description: String?,
        website: String?,
        likes: [String]?,
        completion: @escaping ProfileCompletion
    )
}

final class ProfileRepositoryImpl: ProfileRepository {

    // MARK: - Private Properties

    private let profileService: ProfileService

    // MARK: - Init

    init(profileService: ProfileService) {
        self.profileService = profileService
    }

    // MARK: - Public Methods

    func fetchUserProfile(completion: @escaping ProfileCompletion) {
        profileService.getProfile(completion: completion)
    }

    func updateProfile(
        name: String?,
        avatar: String?,
        description: String?,
        website: String?,
        likes: [String]?,
        completion: @escaping ProfileCompletion
    ) {
        profileService.updateProfile(
            name: name,
            avatar: avatar,
            description: description,
            website: website,
            likes: likes,
            completion: completion
        )
    }
}
