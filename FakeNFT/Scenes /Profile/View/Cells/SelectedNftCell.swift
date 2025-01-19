//
//  SelectedNftCell.swift
//  FakeNFT
//
//  Created by  Admin on 28.12.2024.
//

import UIKit

final class SelectedNftCell: UICollectionViewCell, ReuseIdentifying {

    // MARK: - Private Properties
    private var id: String?
    private var onLikeButtonTap: ((NFT) -> Void)?
    private var isUpdatingLike: Bool = false

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold17
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var ratingView = UIRating(rating: 0)

    private lazy var priceValueLabel: UILabel = {
        let label = UILabel()
        label.font = .regular15
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.font = .regular15
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var nftImageView: NftImageView = {
        let imageView = NftImageView()
        imageView.applyCornerRadius(.small12)
        return imageView
    }()

    private lazy var favoriteButtonView: LikeButtonView = {
        let view = LikeButtonView()
        view.setTintColor(.ypRedUniversal)
        return view
    }()

    // MARK: - Stack Views

    private lazy var commonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nftImageView, informationStackView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, ratingView, priceStackView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.layoutMargins = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        stackView.spacing = 4
        return stackView
    }()

    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceValueLabel, coinLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .background
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension SelectedNftCell {
    private func setupUI() {
        [commonStackView, favoriteButtonView].forEach {
            contentView.setupView($0)
        }
        commonStackView.constraintEdges(to: contentView)

        NSLayoutConstraint.activate([
            nftImageView.heightAnchor.constraint(equalToConstant: UIConstants.Heights.height80),
            nftImageView.widthAnchor.constraint(equalToConstant: UIConstants.Heights.height80),

            favoriteButtonView.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            favoriteButtonView.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            favoriteButtonView.widthAnchor.constraint(equalToConstant: UIConstants.Heights.height30),
            favoriteButtonView.heightAnchor.constraint(equalToConstant: UIConstants.Heights.height30)
        ])
        favoriteButtonView.onTap = handleFavoriteButtonTap
    }
}

// MARK: - NFTCellProtocol

extension SelectedNftCell: NFTCellProtocol {

    func configure(with nft: NFT, isLiked: Bool, priceText: String, currencyText: String, onLikeButtonTap: @escaping (NFT) -> Void) {
        titleLabel.text = nft.name
        priceValueLabel.text = priceText
        coinLabel.text = currencyText
        ratingView.updateRating(nft.rating)
        nftImageView.setNftImage(from: nft.images.first)
        self.id = nft.id
        self.onLikeButtonTap = onLikeButtonTap
        self.isUpdatingLike = false
    }

    func completeLikeUpdate() {
        isUpdatingLike = false
    }

    func revertLikeUpdate(isLiked: Bool) {
        isUpdatingLike = false
    }
}

// MARK: - Action

extension SelectedNftCell {
    private func handleFavoriteButtonTap() {
        guard let id, !isUpdatingLike else { return }
        isUpdatingLike = true

        let dummyNFT = NFT(
            createdAt: "",
            name: titleLabel.text ?? "",
            images: [],
            rating: 0,
            description: "",
            price: 0,
            author: "",
            id: id
        )
        onLikeButtonTap?(dummyNFT)
    }
}
