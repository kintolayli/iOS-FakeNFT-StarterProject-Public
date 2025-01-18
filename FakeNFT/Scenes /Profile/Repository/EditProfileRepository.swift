//
//  EditProfileRepository.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

protocol EditProfileRepository {
    func saveProfileChanges(
        updatedProfile: Profile,
        completion: @escaping (Result<Profile, Error>) -> Void
    )
}

final class EditProfileRepositoryImpl: EditProfileRepository {

    // MARK: - Private Properties

    private let profileService: ProfileService

    // MARK: - Init

    init(profileService: ProfileService) {
        self.profileService = profileService
    }

    // MARK: - Public Methods

    func saveProfileChanges(
        updatedProfile: Profile,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        profileService.updateProfile(
            name: updatedProfile.name,
            avatar: updatedProfile.avatar,
            description: updatedProfile.description,
            website: updatedProfile.website,
            likes: updatedProfile.likes,
            completion: completion
        )
    }
}
