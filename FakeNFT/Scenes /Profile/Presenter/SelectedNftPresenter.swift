//
//  SelectedNftPresenter.swift
//  FakeNFT
//
//  Created by  Admin on 28.12.2024.
//

import Foundation

protocol SelectedNftPresenterProtocol: AnyObject {
    var nfts: [NFT] { get set }
    var isLoading: Bool { get set }

    func viewDidLoad()
    func configureCell(_ cell: NFTCellProtocol, with nft: NFT, isLiked: Bool, priceText: String, currencyText: String)
    func isLiked(nft: NFT) -> Bool
}

final class SelectedNftPresenter {

    // MARK: - Public Properties

    weak var view: SelectedNftProtocol?
    var nfts: [NFT] = []
    var isLoading = false

    // MARK: - Private Properties

    private let likeService: NftLikeService
    private let nftService: MyNftService

    // MARK: - Init

    init(likeService: NftLikeService, nftService: MyNftService) {
        self.likeService = likeService
        self.nftService = nftService
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        loadAllLikedNfts()
    }
}

// MARK: - Load Nfts

extension SelectedNftPresenter {

    private func loadAllLikedNfts() {
        setLoading(true)

        likeService.fetchAllLikes { [weak self] result in
            switch result {
            case .success(let likedIds):
                self?.loadNfts(for: likedIds)
            case .failure(let error):
                self?.setLoading(false)
                Logger.shared.error("Ошибка загрузки всех лайков: \(error.localizedDescription)")
            }
        }
    }

    private func loadNfts(for likedIds: [String]) {
        nftService.loadAllNfts(ids: likedIds) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let likedNfts):
                self.nfts = likedNfts
                self.setLoading(false)
                self.view?.reloadData()
            case .failure(let error):
                Logger.shared.error("Ошибка загрузки лайкнутых NFT: \(error.localizedDescription)")
                self.setLoading(false)
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        self.isLoading = loading
        self.view?.reloadData()
    }
}

// MARK: - SelectedNftPresenterProtocol

extension SelectedNftPresenter: SelectedNftPresenterProtocol {

    @discardableResult
    func isLiked(nft: NFT) -> Bool {
        return likeService.isLiked(nftId: nft.id)
    }

    func configureCell(_ cell: NFTCellProtocol, with nft: NFT, isLiked: Bool, priceText: String, currencyText: String) {
        cell.configure(with: nft, isLiked: isLiked, priceText: priceText, currencyText: currencyText) { likedNFT in
            self.toggleLike(for: likedNFT)
        }
    }
}

// MARK: - Like handler

extension SelectedNftPresenter {

    private func toggleLike(for nft: NFT) {
        guard let index = nfts.firstIndex(where: { $0.id == nft.id }) else { return }

        view?.cellForItem(at: index)?.completeLikeUpdate()

        likeService.toggleLike(for: nft.id) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let isLiked):
                    if !isLiked {
                        self.nfts.remove(at: index)
                        self.view?.deleteItem(at: index)
                    } else {
                        self.view?.reloadItem(at: index)
                    }
                case .failure(let error):
                    Logger.shared.error("[SelectedNftPresenter] - Ошибка при изменении лайка: \(error.localizedDescription)")
                    let previousIsLiked = self.isLiked(nft: nft)
                    self.view?.cellForItem(at: index)?.revertLikeUpdate(isLiked: previousIsLiked)
                }
            }
        }
    }
}
