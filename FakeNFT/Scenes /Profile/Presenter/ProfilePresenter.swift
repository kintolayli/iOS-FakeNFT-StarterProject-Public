//
//  ProfilePresenter.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    var cellsItems: [CategoryCell] { get }
    var myNftValueCount: Int { get set }
    var selectedNftValueCount: Int { get set }

    func viewDidLoad()
    func getCellsTitle(for items: Int) -> String?
    func didTapEditProfile()
    func didTapMyNft()
    func didTapSelectedNft()
    func didTapWebsite()
    func didTapAboutDev()
    func updateUserProfile(_ profile: Profile?)
    func updateUserProfileImage()
}

final class ProfilePresenter {

    // MARK: - Public Properties

    weak var view: ProfileViewControllerProtocol?
    var cellsItems: [CategoryCell] = [.myNft, .selectedNft, .aboutDev]
    var myNftValueCount = 0
    var selectedNftValueCount = 0

    // MARK: - Private Properties

    private let router: ProfileRouterProtocol
    private var profile: Profile?
    private let repository: ProfileRepository

    // MARK: - Init

    init(
        router: ProfileRouterProtocol,
        repository: ProfileRepository
    ) {
        self.router = router
        self.repository = repository
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - ProfilePresenterProtocol

extension ProfilePresenter: ProfilePresenterProtocol {
    func viewDidLoad() {
        fetchUserProfile()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLikeStatusChange(notification:)),
            name: .nftLikeStatusChanged,
            object: nil
        )
    }

    func getCellsTitle(for items: Int) -> String? {
        return cellsItems[items].title
    }

    func didTapEditProfile() {
        if let profile {
            router.navigateToEditProfile(profile, delegate: self)
        }
    }

    func didTapMyNft() {
        if let profile {
            router.navigateToMyNFT(profile)
        }
    }

    func didTapSelectedNft() {
        if let profile {
            router.navigateToSelectedNFT(profile.likes)
        }
    }

    func didTapWebsite() {
        if let profile {
            router.navigateToWebsite(websiteURL: profile.website)
        }
    }

    func didTapAboutDev() {
        router.navigateToAboutTheDeveloper()
    }

    func updateUserProfile(_ profile: Profile?) {
        if let profile {
            self.profile = profile
            self.myNftValueCount = profile.nfts.count
            self.selectedNftValueCount = profile.likes.count
            view?.updateProfileDetails(profile: profile)
        }
    }

    func updateUserProfileImage() {
        if let profile {
            view?.updateUserProfileImageView(profile: profile, mode: .view)
        }
    }
}

// MARK: - Actions

extension ProfilePresenter {

    @objc private func handleLikeStatusChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isLiked = userInfo["isLiked"] as? Bool else { return }

        if isLiked {
            selectedNftValueCount += 1
        } else {
            selectedNftValueCount -= 1
        }

        view?.updateProfileDetails(profile: profile)
    }
}

// MARK: - Fetching Profile Data from Network

extension ProfilePresenter {
    private func fetchUserProfile() {
        repository.fetchUserProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.updateUserProfile(profile)
            case .failure(let error):
                self.handleError(error)
                Logger.shared.error("Error fetching profile: \(error)")
            }
        }
    }
}

// MARK: - Show Error

extension ProfilePresenter {
    private func handleError(_ error: Error) {
        let errorMessage = (error as? CustomError)?.localizedDescription ?? LocalizationKey.errorUnknown.localized()

        let errorModel = ErrorModel(
            message: errorMessage,
            actionText: LocalizationKey.errorRepeat.localized(),
            action: { [weak self] in
                self?.fetchUserProfile()
            }
        )

        if let view = self.view as? ErrorView {
            view.showError(errorModel)
        }
    }
}

// MARK: - EditProfilePresenterDelegate

extension ProfilePresenter: EditProfilePresenterDelegate {
    func didUpdateProfile(_ profile: Profile) {
        self.profile = profile
        view?.updateProfileDetails(profile: profile)
    }
}
