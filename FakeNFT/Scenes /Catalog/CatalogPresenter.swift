//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import Foundation


protocol CatalogPresenterProtocol: AnyObject {
    var collections: [NFTCollectionModel] { get set }
    var viewController: CatalogViewControllerProtocol? { get set }
    var isLoading: Bool { get set }

    func loadInitialData()
    func filterButtonTapped()
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
        isLoading = UIBlockingProgressHUD.status()
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

    func loadInitialData() {
        UIBlockingProgressHUD.show()

        catalogService.fetchCatalog() { [weak self] result in
            guard let self = self else { return }


            switch result {
            case .success(let collections):
                UIBlockingProgressHUD.dismiss()
                isLoading = false

                self.collections = collections
                self.viewController?.updateView()
                self.applySortMethod()
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
