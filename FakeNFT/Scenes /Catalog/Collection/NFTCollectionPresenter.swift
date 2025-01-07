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
    var isLoading: Bool { get set }

    func loadLikes(profileId: Int)
    func loadNFTsInCart(profileId: Int)
    func loadInitialData(nftIds: [UUID])

    func sendLike(profileId: Int, nftId: UUID, completion: @escaping (Bool) -> Void)
    func sendNFTToCart(profileId: Int, nftId: UUID, completion: @escaping (Bool) -> Void)
}

final class NFTCollectionPresenter: NFTCollectionPresenterProtocol {
    private let nftCollectionService: NFTCollectionService
    private let likeService: NFTLikeService
    private let cartService: NFTCartService
    var isLoading: Bool

    weak var viewController: NFTCollectionViewControllerProtocol?
    var nfts: [NFTModel] = []
    private(set) var likes: [UUID] = []
    private(set) var nftsInCart: [UUID] = []

    init() {
        self.nftCollectionService = NFTCollectionService.shared
        self.likeService = NFTLikeService.shared
        self.cartService = NFTCartService.shared
        isLoading = UIBlockingProgressHUD.status()
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
                viewController?.reloadData()
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

    func sendLike(profileId: Int, nftId: UUID, completion: @escaping (Bool) -> Void) {
        UIBlockingProgressHUD.show()

        likeService.sendLike(profileId: profileId, nftId: nftId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                loadLikes(profileId: profileId)
                completion(true)

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
                viewController?.reloadData()
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

    func sendNFTToCart(profileId: Int, nftId: UUID, completion: @escaping (Bool) -> Void) {
        UIBlockingProgressHUD.show()

        cartService.sendNFTToCart(profileId: profileId, nftId: nftId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                loadNFTsInCart(profileId: profileId)
                completion(true)

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
                isLoading = false

                self.nfts = nfts
                viewController?.updateView()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                isLoading = false

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
