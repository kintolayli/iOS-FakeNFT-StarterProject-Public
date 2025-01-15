//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import Foundation


protocol CatalogPresenterProtocol: AnyObject {
    var viewController: CatalogViewControllerProtocol? { get set }

    var collections: [NFTCollectionModel] { get set }

    func loadInitialData(completion: @escaping (Bool) -> Void)
    func filterButtonTapped()
    func getCollections() -> [NFTCollectionModel]
    func getCollection(indexPath: IndexPath) -> NFTCollectionModel
    func getLoadingStatus() -> Bool

    func createPlaceholderCollections() -> [NFTCollectionModel]
    func createCollections() -> [NFTCollectionModel]
}

final class CatalogPresenter: CatalogPresenterProtocol {
    private let catalogService: CatalogService
    private var sortMethod: SortMethod

    weak var viewController: CatalogViewControllerProtocol?
    var isLoading: Bool
    var collections: [NFTCollectionModel] = []

    init() {
        self.catalogService = CatalogService.shared
        self.sortMethod = CatalogPresenter.loadSortMethod()
        self.isLoading = UIBlockingProgressHUD.status()
    }

    func filterButtonTapped() {
        let sortType1Title = L10n.CatalogController.SortNFT.sortType1
        let sortType2Title = L10n.CatalogController.SortNFT.sortType2
        let closeTitle = L10n.CatalogController.SortNFT.closeTitle
        let sortTitle = L10n.CatalogController.SortNFT.sortTitle

        let alertModel = AlertModel(
            title: sortTitle,
            message: nil,
            actions: [
                AlertActionModel(title: sortType1Title, style: .default) { [weak self] _ in
                    self?.sortCollectionsAlphabetically()
                },
                AlertActionModel(title: sortType2Title, style: .default) { [weak self] _ in
                    self?.sortCollectionsByNFTCount()
                },
                AlertActionModel(title: closeTitle, style: .cancel, handler: nil),
            ]
        )

        viewController?.showAlert(with: alertModel)
    }

    func loadInitialData(completion: @escaping (Bool) -> Void) {
        catalogService.fetchCatalog() { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let collections):
                isLoading = false

                self.collections = collections
                self.viewController?.updateView()
                self.applySortMethod()
                completion(true)
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
                completion(true)
            }
        }
    }

    func getCollections() -> [NFTCollectionModel] {
        return collections
    }

    func getCollection(indexPath: IndexPath) -> NFTCollectionModel {
        return collections[indexPath.row]
    }

    func getLoadingStatus() -> Bool {
        return isLoading
    }

    func createPlaceholderCollections() -> [NFTCollectionModel] {
        return (0..<Constants.placeholdersCount).map { _ in
            NFTCollectionModel(
                createdAt: "",
                name: "",
                cover: URL(fileURLWithPath: ""),
                nfts: [UUID()],
                description: "",
                author: "",
                id: UUID()
            )
        }
    }

    func createCollections() -> [NFTCollectionModel] {
        return collections.map { collection in
            NFTCollectionModel(
                createdAt: collection.createdAt,
                name: collection.name,
                cover: collection.cover,
                nfts: collection.nfts,
                description: collection.description,
                author: collection.author,
                id: collection.id
            )
        }
    }
}


extension CatalogPresenter {
    private static func loadSortMethod() -> SortMethod {
        let sortMethodRawValue = UserDefaults.standard.string(forKey: "CatalogSortMethod") ?? SortMethod.alphabetically.rawValue
        return SortMethod(rawValue: sortMethodRawValue) ?? .alphabetically
    }

    private func saveSortMethod() {
        DispatchQueue.global(qos: .background).async {
            UserDefaults.standard.set(self.sortMethod.rawValue, forKey: "CatalogSortMethod")
        }
    }

    private func sortCollectionsAlphabetically() {
        collections = collections.sorted { $0.name < $1.name }
        sortMethod = .alphabetically
        saveSortMethod()
        viewController?.updateView()
    }

    private func sortCollectionsByNFTCount() {
        // TODO: - Сервер поломан - в некоторых коллекциях присылается несколько одинаковых NFT с одинаковыми Id, и diffable data source ломается. Строчка ниже это костыль чтобы временно эту проблему решить.
        collections = collections.map { collection in
            let uniqueNFTsIds = Set(collection.nfts.map { $0 })

            let uniqueNFTs = uniqueNFTsIds.compactMap { id in
                collection.nfts.first { $0 == id }
            }
            
            return NFTCollectionModel(
                createdAt: collection.createdAt,
                name: collection.name,
                cover: collection.cover,
                nfts: uniqueNFTs,
                description: collection.description,
                author: collection.author,
                id: collection.id)
        }

        collections = collections.sorted { $0.nfts.count > $1.nfts.count }
        sortMethod = .byNFTCount
        saveSortMethod()
        viewController?.updateView()
    }

    private func applySortMethod() {
        switch sortMethod {
        case .alphabetically:
            sortCollectionsAlphabetically()
        case .byNFTCount:
            sortCollectionsByNFTCount()
        }
    }
}
