//
//  NFTCollectionPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 05.01.2025.
//

import Foundation


protocol NFTCollectionPresenterProtocol: AnyObject {
    var viewController: NFTCollectionViewControllerProtocol?  { get set }
    var nfts: [NFTModel] { get set }
    var likes: [UUID] { get }
    var nftsInCart: [UUID] { get }

    func loadLikes(profileId: Int)
    func loadNFTsInCart(profileId: Int)
    func loadInitialData(nftIds: [UUID])

    func sendLike(profileId: Int, nftId: UUID)
    func sendNFTToCart(profileId: Int, nftId: UUID)
}

final class NFTCollectionPresenter: NFTCollectionPresenterProtocol {
    private let nftCollectionService: NFTCollectionService
    private let likeService: NFTLikeService
    private let cartService: NFTCartService

    weak var viewController: NFTCollectionViewControllerProtocol?
    var nfts: [NFTModel] = []
    private(set) var likes: [UUID] = []
    private(set) var nftsInCart: [UUID] = []

    init() {
        self.nftCollectionService = NFTCollectionService.shared
        self.likeService = NFTLikeService.shared
        self.cartService = NFTCartService.shared
    }

    func loadLikes(profileId: Int) {
        UIBlockingProgressHUD.show()

        likeService.fetchLikes(profileId: profileId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(let likedNFT):
                UIBlockingProgressHUD.dismiss()

                likes = likedNFT
                viewController?.updateView()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()

                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                viewController?.showAlert(with: alertModel)
            }
        }
    }

    func sendLike(profileId: Int, nftId: UUID) {
        UIBlockingProgressHUD.show()

        likeService.sendLike(profileId: profileId, nftId: nftId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                loadLikes(profileId: profileId)

            case .failure(_):
                UIBlockingProgressHUD.dismiss()

                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                viewController?.showAlert(with: alertModel)
            }
        }
    }

    func loadNFTsInCart(profileId: Int) {
        UIBlockingProgressHUD.show()

        cartService.fetchNFTInCart(profileId: profileId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(let nfts):
                UIBlockingProgressHUD.dismiss()

                nftsInCart = nfts
                viewController?.updateView()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()

                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingCartError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                viewController?.showAlert(with: alertModel)
            }
        }
    }

    func sendNFTToCart(profileId: Int, nftId: UUID) {
        UIBlockingProgressHUD.show()

        cartService.sendNFTToCart(profileId: profileId, nftId: nftId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                loadNFTsInCart(profileId: profileId)

            case .failure(_):
                UIBlockingProgressHUD.dismiss()

                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                viewController?.showAlert(with: alertModel)
            }
        }
    }

    func loadInitialData(nftIds: [UUID]) {
        UIBlockingProgressHUD.show()

        nftCollectionService.fetchNFT(ids: nftIds) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let nfts):
                UIBlockingProgressHUD.dismiss()

                self.nfts = nfts
                viewController?.updateView()
            case .failure:
                UIBlockingProgressHUD.dismiss()

                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.unknown,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                viewController?.showAlert(with: alertModel)
            }
        }
    }
}
