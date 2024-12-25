//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import UIKit
import Kingfisher


protocol CatalogPresenterProtocol {
    var viewController: CatalogViewControllerProtocol { get set }
    func configCell(for cell: CatalogTableViewCell, with indexPath: IndexPath)
}

final class CatalogPresenter: CatalogPresenterProtocol {
    var viewController: CatalogViewControllerProtocol

    init(viewController: CatalogViewControllerProtocol) {
        self.viewController = viewController
    }

    func configCell(for cell: CatalogTableViewCell, with indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let NFTCollectionCoverImageURL = viewController.catalog[indexPath.item].cover
        let imageView = UIImageView()
        let processor = RoundCornerImageProcessor(cornerRadius: 12)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: NFTCollectionCoverImageURL,
                              placeholder: .none,
                              options: [.processor(processor)]) { result in
            switch result {
            case .success:

                let collectionCount = self.viewController.catalog[indexPath.item].nfts.count
                let collectionName = self.viewController.catalog[indexPath.item].name
                let collectionTitle = "\(collectionName) (\(collectionCount))"

                guard let collectionImage = imageView.image else { return }

                cell.updateCell(titleLabel: collectionTitle, titleImage: collectionImage)

                self.viewController.reloadRows(indexPath: indexPath)
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
}
