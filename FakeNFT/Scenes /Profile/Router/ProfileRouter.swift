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
}

final class ProfileRouter {

    weak var viewController: UIViewController?
    private let profileService: ProfileService

    // Закомментированные лишние зависимости
    // private let nftService: // MyNftService (закомментировано)
    // private let likeService: // NftLikeService (закомментировано)

    init(profileService: ProfileService) {
        self.profileService = profileService
    }
}

// MARK: - ProfileRouterProtocol
extension ProfileRouter: ProfileRouterProtocol {

    func navigateToEditProfile(_ profile: Profile?, delegate: EditProfilePresenterDelegate) {
        guard let viewController else { return }

        let repository = EditProfileRepositoryImpl(profileService: profileService)
        let presenter = EditProfilePresenter(profile: profile, repository: repository)
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
            print("Неверный или неподдерживаемый URL: \(urlString)")
            return
        }

        let websiteViewController = SFSafariViewController(url: url)
        websiteViewController.hidesBottomBarWhenPushed = true
        viewController.navigationController?.present(websiteViewController, animated: true)
    }
}
