//
//  ProfileRouter.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import SafariServices
import UIKit

protocol ProfileRouterProtocol: AnyObject {
    func navigateToEditProfile(_ profile: Profile?, delegate: EditProfilePresenterDelegate)
    func navigateToWebsite(websiteURL: String)
    func navigateToMyNFT(_ profile: Profile?)
    func navigateToSelectedNFT(_ profileNftLikes: [String]?)
    func navigateToAboutTheDeveloper()
}

final class ProfileRouter {

    // MARK: - Public Properties

    weak var viewController: UIViewController?

    // MARK: - Private Properties

    private let profileService: ProfileService
    private let nftService: MyNftService
    private let likeService: NftLikeService

    // MARK: - Init

    init(profileService: ProfileService, nftService: MyNftService, likeService: NftLikeService) {
        self.profileService = profileService
        self.nftService = nftService
        self.likeService = likeService
    }
}

// MARK: - ProfileRouterProtocol

extension ProfileRouter: ProfileRouterProtocol {

    // MARK: - Public Methods

    func navigateToEditProfile(_ profile: Profile?, delegate: EditProfilePresenterDelegate) {
        guard let viewController else { return }

        let profileService = self.profileService
        let repository = EditProfileRepositoryImpl(profileService: profileService)
        let presenter = EditProfilePresenter(
            profile: profile,
            repository: repository
        )
        presenter.delegate = delegate

        let editProfileViewController = EditProfileViewController(presenter: presenter)
        presenter.view = editProfileViewController

        editProfileViewController.modalPresentationStyle = .formSheet

        DispatchQueue.main.async {
            viewController.present(editProfileViewController, animated: true)
        }
    }

    func navigateToWebsite(websiteURL: String) {
        var urlString = websiteURL
        if !websiteURL.lowercased().hasPrefix("http://") && !websiteURL.lowercased().hasPrefix("https://") {
            urlString = "https://\(websiteURL)"
        }

        guard let viewController,
              let url = URL(string: urlString),
              ["http", "https"].contains(url.scheme?.lowercased()) else {
            Logger.shared.error("Неверный или неподдерживаемый URL: \(urlString)")
            return
        }

        let websiteViewController = SFSafariViewController(url: url)
        websiteViewController.hidesBottomBarWhenPushed = true
        viewController.navigationController?.present(websiteViewController, animated: true)
    }

    func navigateToMyNFT(_ profile: Profile?) {
        guard let viewController, let profile else { return }

        let nftIds = profile.nfts

        let repository = MyNftRepositoryImpl(
            nftService: self.nftService,
            profileService: self.profileService
        )

        let presenter = MyNftPresenter(
            repository: repository,
            nftIds: nftIds,
            likeService: likeService
        )

        let myNftController = MyNftViewController(presenter: presenter)
        presenter.view = myNftController

        myNftController.hidesBottomBarWhenPushed = true

        DispatchQueue.main.async {
            viewController.navigationController?.pushViewController(myNftController, animated: true)
        }
    }

    func navigateToSelectedNFT(_ profileNftLikes: [String]?) {
        guard let viewController else { return }

        let presenter = SelectedNftPresenter(likeService: likeService, nftService: nftService)

        let selectedNftViewController = SelectedNftViewController(presenter: presenter)
        presenter.view = selectedNftViewController

        selectedNftViewController.hidesBottomBarWhenPushed = true

        DispatchQueue.main.async {
            viewController.navigationController?.pushViewController(selectedNftViewController, animated: true)
        }
    }

    func navigateToAboutTheDeveloper() {
        let urlString = NetworkConstants.urlDev

        guard let viewController else { return }

        let websiteViewController = WebViewWithProgressViewController(url: urlString)
        websiteViewController.hidesBottomBarWhenPushed = true
        if let navigationController = viewController.navigationController {
            navigationController.pushViewController(websiteViewController, animated: true)
        } else {
            viewController.present(websiteViewController, animated: true, completion: nil)
        }
    }
}
