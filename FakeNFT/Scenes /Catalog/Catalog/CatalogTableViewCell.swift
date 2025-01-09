//
//  CatalogTableViewCell.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 23.12.2024.
//

import UIKit


final class CatalogTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CatalogTableViewCell"
    weak var delegate: CatalogViewControllerProtocol?

    private let cellTitleImage: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let cellTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = Asset.ypBlack.color
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }

    override func prepareForReuse() {
        super.prepareForReuse( )
    }

    func startShimmering() {
        cellTitleImage.addShimmer()
        let grayImage = UIImage.from(color: .segmentInactive, size: CGSize(width: 343, height: 140))
        cellTitleImage.image = grayImage

        cellTitleLabel.addShimmer()
        cellTitleLabel.text = L10n.loading
        cellTitleLabel.textColor = .segmentInactive
    }

    func stopShimmering() {
        cellTitleImage.removeShimmer()

        cellTitleLabel.removeShimmer()
        cellTitleLabel.textColor = Asset.ypBlack.color
    }

    func updateCell(titleLabel: String, titleImage: UIImage) {
        DispatchQueue.main.async {
            self.cellTitleLabel.text = titleLabel.capitalized
            self.cellTitleImage.image = titleImage
        }
    }

    private func setupUI() {
        [cellTitleImage, cellTitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate( [
            cellTitleImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellTitleImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitleImage.topAnchor.constraint(equalTo: contentView.topAnchor),

            cellTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellTitleLabel.topAnchor.constraint(equalTo: cellTitleImage.bottomAnchor, constant: 4),
            cellTitleImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -35),
        ])
    }
}
