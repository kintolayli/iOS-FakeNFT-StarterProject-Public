//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import UIKit
import Kingfisher


protocol CatalogPresenterProtocol {
    var collections: [NFTCollectionModel] { get set }

    func loadInitialData()
    func filterButtonTapped()
    func sortCollectionsAlphabetically()
    func sortCollectionsByNFTCount()
    func applySortMethod()
    func configCell(for cell: CatalogTableViewCell, with indexPath: IndexPath)
}

final class CatalogPresenter: CatalogPresenterProtocol {
    var viewController: CatalogViewControllerProtocol?
    private let catalogService: CatalogService
    private var sortMethod: SortMethod

    var collections: [NFTCollectionModel] = []

    init(catalogService: CatalogService) {
        self.catalogService = catalogService
        self.sortMethod = CatalogPresenter.loadSortMethod()
    }

    func filterButtonTapped() {
        let sortType1Title = L10n.CatalogController.SortNFT.sortType1
        let sortType2Title = L10n.CatalogController.SortNFT.sortType2
        let closeTitle = L10n.CatalogController.SortNFT.closeTitle
        let sortTitle = L10n.CatalogController.SortNFT.sortTitle

        let model = AlertModel(
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
        guard let viewController = viewController as? CatalogViewController else { return }

        AlertPresenter.show(model: model, viewController: viewController, preferredStyle: .actionSheet)
    }

    func sortCollectionsAlphabetically() {
        collections = collections.sorted { $0.name < $1.name }
        sortMethod = .alphabetically
        saveSortMethod()
        viewController?.updateView()
    }

    func sortCollectionsByNFTCount() {
        collections = collections.sorted { $0.nfts.count > $1.nfts.count }
        sortMethod = .byNFTCount
        saveSortMethod()
        viewController?.updateView()
    }

    func configCell(for cell: CatalogTableViewCell, with indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let NFTCollectionCoverImageURL = collections[indexPath.item].cover
        let imageView = UIImageView()
        let processor = RoundCornerImageProcessor(cornerRadius: 12)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: NFTCollectionCoverImageURL,
                              placeholder: .none,
                              options: [.processor(processor)]) { result in
            switch result {
            case .success:

                let collectionCount = self.collections[indexPath.item].nfts.count
                let collectionName = self.collections[indexPath.item].name
                let collectionTitle = "\(collectionName) (\(collectionCount))"

                guard let collectionImage = imageView.image else { return }

                cell.updateCell(titleLabel: collectionTitle, titleImage: collectionImage)

            case .failure(let error):
                let logMessage =
                """
                [\(String(describing: self)).\(#function)]:
                \(CatalogPresenterError.fetchImageError) - Ошибка получения изображения ячейки таблицы, \(error.localizedDescription)
                """
                print(logMessage)
            }
        }
    }

    func loadInitialData() {
        collections = catalogService.catalog
        applySortMethod()
    }

    func applySortMethod() {
        switch sortMethod {
        case .alphabetically:
            sortCollectionsAlphabetically()
        case .byNFTCount:
            sortCollectionsByNFTCount()
        }
    }

    private static func loadSortMethod() -> SortMethod {
        let sortMethodRawValue = UserDefaults.standard.string(forKey: "CatalogSortMethod") ?? SortMethod.alphabetically.rawValue
        return SortMethod(rawValue: sortMethodRawValue) ?? .alphabetically
    }

    private func saveSortMethod() {
        UserDefaults.standard.set(sortMethod.rawValue, forKey: "CatalogSortMethod")
    }

}
