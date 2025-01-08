//
//  NFTCollectionPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 05.01.2025.
//

import Foundation


protocol NFTCollectionPresenterProtocol: AnyObject {
    var viewController: NFTCollectionViewControllerProtocol?  { get set }

    func getLoadingStatus() -> Bool
    func getCellData() -> (likes: [UUID], nftsInCart: [UUID])
    func getNfts() -> [NFTModel]
    func getNft(indexPath: IndexPath) -> NFTModel

    func createPlaceholderNFTs() -> [NFTModel]
    func createNFTs() -> [NFTModel]

    func loadInitialData(completion: @escaping (Bool) -> Void)

    func sendLike(nftId: UUID, completion: @escaping (Bool) -> Void)
    func sendNFTToCart(nftId: UUID, completion: @escaping (Bool) -> Void)
}

final class NFTCollectionPresenter: NFTCollectionPresenterProtocol {
    private let nftCollectionService: NFTCollectionService
    private let likeService: NFTLikeService
    private let cartService: NFTCartService
    private let currentCollection: NFTCollectionModel
    private var nfts: [NFTModel] = []
    private var likes: [UUID] = []
    private var nftsInCart: [UUID] = []
    private var isLoading: Bool
    private var profileId = 1

    weak var viewController: NFTCollectionViewControllerProtocol?

    init(currentCollection: NFTCollectionModel) {
        self.currentCollection = currentCollection
        self.nftCollectionService = NFTCollectionService.shared
        self.likeService = NFTLikeService.shared
        self.cartService = NFTCartService.shared
        self.isLoading = UIBlockingProgressHUD.status()
    }

    func loadLikes() {
        likeService.fetchLikes(profileId: profileId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(let likedNFT):
                likes = likedNFT
                viewController?.updateView()
                viewController?.reloadData()
            case .failure(_):
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

    func sendLike(nftId: UUID, completion: @escaping (Bool) -> Void) {
        likeService.sendLike(profileId: profileId, nftId: nftId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                loadLikes()
                completion(true)

            case .failure(_):
                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                completion(true)
                viewController?.showAlert(with: alertModel)
            }
        }
    }

    func loadNFTsInCart() {
        cartService.fetchNFTInCart(profileId: profileId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(let nfts):
                nftsInCart = nfts
                viewController?.updateView()
                viewController?.reloadData()
            case .failure(_):
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

    func sendNFTToCart(nftId: UUID, completion: @escaping (Bool) -> Void) {
        cartService.sendNFTToCart(profileId: profileId, nftId: nftId) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                loadNFTsInCart()
                completion(true)

            case .failure(_):
                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                completion(true)
                viewController?.showAlert(with: alertModel)
            }
        }
    }

    func loadNfts(nftIds: [UUID]) {
        nftCollectionService.fetchNFT(ids: nftIds) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let nfts):
                isLoading = false

                self.nfts = nfts
                viewController?.updateView()
            case .failure:
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

    func loadInitialData(completion: @escaping (Bool) -> Void) {
        loadLikes()
        loadNFTsInCart()
        // TODO: - Сервер поломан - в некоторых коллекциях присылается несколько одинаковых NFT с одинаковыми Id, и diffable data source ломается. Строчка ниже это костыль чтобы временно эту проблему решить.
        let nftsUnique = Array(Set(currentCollection.nfts))
        loadNfts(nftIds: nftsUnique)
        completion(true)
    }

    func createPlaceholderNFTs() -> [NFTModel] {
        return (0..<6).map { nft in
            NFTModel(
                createdAt: "",
                name: "",
                images: [URL(fileURLWithPath: "")],
                rating: 5,
                description: "",
                price: 0.00,
                author: URL(fileURLWithPath: ""),
                id: UUID()
            )
        }
    }

    func createNFTs() -> [NFTModel] {
        return nfts.map { nft in
            NFTModel(
                createdAt: nft.createdAt,
                name: nft.name,
                images: nft.images,
                rating: nft.rating,
                description: nft.description,
                price: nft.price,
                author: nft.author,
                id: nft.id
            )
        }
    }

    func getLoadingStatus() -> Bool {
        return isLoading
    }

    func getCellData() -> (likes: [UUID], nftsInCart: [UUID]) {
        return (likes: likes, nftsInCart: nftsInCart)
    }

    func getNfts() -> [NFTModel] {
        return nfts
    }

    func getNft(indexPath: IndexPath) -> NFTModel {
        return nfts[indexPath.row]
    }
}
