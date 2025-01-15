//
//  NftImageCollectionViewTopCell.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 15.01.2025.
//

import UIKit

final class NftImageCollectionViewTopCell: UICollectionViewCell {
    static let reuseIdentifier = "NftImageCollectionViewTopCell"

    // MARK: - Properties

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        imageView.constraintCenters(to: contentView)
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions

    func configure(with cellModel: NftDetailCellModel) {
        imageView.kf.setImage(with: cellModel.url)
    }
}
