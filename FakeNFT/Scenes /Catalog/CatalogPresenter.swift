//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//


protocol CatalogPresenterProtocol: AnyObject {
    var collections: [NFTCollectionModel] { get set }
    var viewController: CatalogViewControllerProtocol? { get set }

    func loadInitialData()
    func filterButtonTapped()
    func sortCollectionsAlphabetically()
    func sortCollectionsByNFTCount()
}

final class CatalogPresenter: CatalogPresenterProtocol {
    weak var viewController: CatalogViewControllerProtocol?
    private let catalogService: CatalogService

    var collections: [NFTCollectionModel] = []

    init() {
        self.catalogService = CatalogService.shared
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
                    self?.viewController?.sortCollectionsAlphabetically()
                },
                AlertActionModel(title: sortType2Title, style: .default) { [weak self] _ in
                    self?.viewController?.sortCollectionsByNFTCount()
                },
                AlertActionModel(title: closeTitle, style: .cancel, handler: nil),
            ]
        )

        viewController?.showAlert(with: alertModel)
    }

    func sortCollectionsAlphabetically() {
        collections = collections.sorted { $0.name < $1.name }
    }

    func sortCollectionsByNFTCount() {
        collections = collections.sorted { $0.nfts.count > $1.nfts.count }
    }

    func loadInitialData() {
        UIBlockingProgressHUD.show()

        catalogService.fetchCatalog() { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let collections):
                UIBlockingProgressHUD.dismiss()

                self.collections = collections
                self.viewController?.updateRowsAnimated(newCollections: catalogService.catalog, oldCollections: collections)
                self.viewController?.applySortMethod()
            case .failure:
                UIBlockingProgressHUD.dismiss()

                let alertModel = AlertModel(
                    title: L10n.Error.unknown,
                    message: L10n.Error.unknown,
                    actions: [
                        AlertActionModel(title: L10n.Error.unknown, style: .cancel, handler: nil)
                    ]
                )
                viewController?.showAlert(with: alertModel)
            }
        }
    }
}
