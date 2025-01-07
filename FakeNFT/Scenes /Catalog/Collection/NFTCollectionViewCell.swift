//
//  NFTCollectionViewCell.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 04.01.2025.
//

import UIKit


class NFTCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "NFTCollectionViewCell"
    var delegate: NFTCollectionViewControllerProtocol?

    private lazy var mainImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)

        let heartImage = UIImage(systemName: "heart.fill")
        button.setImage(heartImage, for: .normal)
        button.tintColor = Asset.ypWhite.color

        button.layer.shadowColor = Asset.ypBlack.color.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowRadius = 5

        button.backgroundColor = .clear
        button.adjustsImageWhenHighlighted = true

        return button
    }()

    private lazy var ratingStackView: UIStackView = {
        let stars = (0..<5).map { _ -> UIImageView in
            let imageView = UIImageView()
            imageView.image = Asset.star.image.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = Asset.ypLightGrey.color
            return imageView
        }

        let stackView = UIStackView(arrangedSubviews: stars)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        stackView.alignment = .leading

        return stackView
    }()

    lazy var cartButton: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(Asset.cartAdd.image, for: .normal)
        button.tintColor = Asset.ypBlack.color

        button.backgroundColor = .clear
        button.adjustsImageWhenHighlighted = true

        return button
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = Asset.ypBlack.color
        label.textAlignment = .left
        label.font = .bodyBold

        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()

        label.textColor = Asset.ypBlack.color
        label.textAlignment = .left
        label.font = .price1

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        [mainImageView, likeButton, ratingStackView, cartButton, titleLabel, priceLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor),

            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9),
            likeButton.widthAnchor.constraint(equalToConstant: 28),
            likeButton.heightAnchor.constraint(equalTo: likeButton.widthAnchor),

            ratingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            ratingStackView.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 4),

            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            cartButton.trailingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: -11),
            cartButton.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 35),
        ])

        likeButton.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(cartButtonDidTap), for: .touchUpInside)
    }

    @objc
    func likeButtonDidTap() {
        delegate?.likeButtonDidTap(self)
    }

    @objc
    func cartButtonDidTap() {
        delegate?.cartButtonDidTap(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startShimmering() {
        mainImageView.addShimmer()
        let grayImage = UIImage.from(color: .segmentInactive, size: CGSize(width: 343, height: 140))
        mainImageView.image = grayImage

        ratingStackView.addShimmer()
        cartButton.addShimmer()
        cartButton.isHidden = true
        likeButton.isHidden = true

        titleLabel.addShimmer()
        titleLabel.text = "loading"
        titleLabel.textColor = .segmentInactive

        priceLabel.addShimmer()
        priceLabel.text = "loading"
        priceLabel.textColor = .segmentInactive
    }

    func stopShimmering() {
        mainImageView.removeShimmer()
        ratingStackView.removeShimmer()
        cartButton.removeShimmer()
        cartButton.isHidden = false
        likeButton.isHidden = false

        titleLabel.removeShimmer()
        titleLabel.textColor = Asset.ypBlack.color

        priceLabel.removeShimmer()
        priceLabel.textColor = Asset.ypBlack.color
    }

    func clearRating() {
        for item in 0..<5 {
            ratingStackView.arrangedSubviews[item].tintColor = Asset.ypLightGrey.color
        }
    }

    func setRating(ratingCount: Int) {
        for item in 0..<ratingCount {
            ratingStackView.arrangedSubviews[item].tintColor = Asset.ypYellow.color
        }
    }

    func getCurrentCurrency() -> String {
        return "ETH"
    }

    func clearCell() {
        clearRating()
        likeButton.tintColor = Asset.ypWhite.color
        cartButton.setImage(Asset.cartAdd.image, for: .normal)
    }

    func updateCell(
        cell: NFTModel,
        image: UIImage,
        profileLikes: [UUID],
        nftsInCart: [UUID]
    ) {
        clearCell()
        mainImageView.image = image

        let parts = cell.name.split(separator: " ")
        titleLabel.text = String(parts[0])

        let currentCurrency = getCurrentCurrency()
        priceLabel.text = "\(cell.price) \(currentCurrency)"

        setRating(ratingCount: cell.rating)

        if profileLikes.contains(cell.id) {
            likeButton.tintColor = Asset.ypRed.color
        } else {
            likeButton.tintColor = Asset.ypWhite.color
        }

        if nftsInCart.contains(cell.id) {
            cartButton.setImage(Asset.cartDelete.image, for: .normal)
        } else {
            cartButton.setImage(Asset.cartAdd.image, for: .normal)
        }
    }
}
