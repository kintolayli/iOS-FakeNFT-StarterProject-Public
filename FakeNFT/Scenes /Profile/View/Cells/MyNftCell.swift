//
//  MyNftCell.swift
//  FakeNFT
//
//  Created by  Admin on 26.12.2024.
//

import UIKit

final class MyNftCell: UITableViewCell, ReuseIdentifying {

    // MARK: - Private Properties

    private var nft: NFT?
    private var onLikeButtonTap: ((NFT) -> Void)?
    private var isUpdatingLike = false

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold17
        return label
    }()

    private lazy var fromLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizationKey.profFromAuthor.localized()
        label.font = UIFont.regular15
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regular13
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regular13
        label.text = LocalizationKey.price.localized()
        return label
    }()

    private lazy var priceValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold17
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bold17
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var nftImageView: NftImageView = {
        let imageView = NftImageView()
        imageView.applyCornerRadius(.small12)
        return imageView
    }()

    private lazy var ratingView = UIRating(rating: 0)

    private lazy var favoriteButtonView: LikeButtonView = {
        let view = LikeButtonView()
        view.setTintColor(.ypLightGrey)
        return view
    }()

    // MARK: - Stack Views

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, ratingView, authorStackView])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = UIConstants.Spacing.small4
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: UIConstants.Insets.large23,
            left: UIConstants.Insets.zero,
            bottom: UIConstants.Insets.large23,
            right: UIConstants.Insets.zero
        )
        return stackView
    }()

    private lazy var priceValueStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceValueLabel, coinLabel])
        stackView.axis = .horizontal
        stackView.spacing = UIConstants.Spacing.small4
        stackView.alignment = .leading
        return stackView
    }()

    private lazy var priceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceLabel, priceValueStackView])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: UIConstants.Insets.large33,
            left: UIConstants.Insets.zero,
            bottom: UIConstants.Insets.large33,
            right: UIConstants.Insets.zero
        )
        stackView.axis = .vertical
        stackView.spacing = UIConstants.Spacing.small2
        return stackView
    }()

    private lazy var authorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fromLabel, authorLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = UIConstants.Spacing.small4
        fromLabel.setContentHuggingPriority(.required, for: .horizontal)
        authorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nftImageView, textStackView, priceStackView])
        stackView.axis = .horizontal
        stackView.spacing = UIConstants.Spacing.large20
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: UIConstants.Insets.small8,
            left: UIConstants.Insets.medium16,
            bottom: UIConstants.Insets.small8,
            right: UIConstants.Insets.large39)
        return stackView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .background
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension MyNftCell {
    private func setupUI() {
        contentView.setupView(contentStackView)
        nftImageView.setupView(favoriteButtonView)
        contentStackView.constraintEdges(to: contentView)

        NSLayoutConstraint.activate([
            priceValueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),

            nftImageView.widthAnchor.constraint(equalToConstant: UIConstants.Heights.height108),
            nftImageView.heightAnchor.constraint(equalToConstant: UIConstants.Heights.height108),

            favoriteButtonView.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            favoriteButtonView.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            favoriteButtonView.widthAnchor.constraint(equalToConstant: UIConstants.Heights.height40),
            favoriteButtonView.heightAnchor.constraint(equalToConstant: UIConstants.Heights.height40)
        ])
        favoriteButtonView.onTap = handleFavoriteButtonTap
    }
}

// MARK: - Configure Cell

extension MyNftCell: NFTCellProtocol {

    func configure(with nft: NFT,
                   isLiked: Bool,
                   priceText: String,
                   currencyText: String,
                   onLikeButtonTap: @escaping (NFT) -> Void) {
        self.nft = nft
        self.onLikeButtonTap = onLikeButtonTap
        self.isUpdatingLike = false

        titleLabel.text = nft.name
        ratingView.updateRating(nft.rating)
        priceValueLabel.text = priceText
        authorLabel.text = nft.author
        nftImageView.setNftImage(from: nft.images.first)
        coinLabel.text = currencyText
        updateFavoriteButton(isLiked: isLiked)
    }

    func completeLikeUpdate() {
        isUpdatingLike = false
    }

    func revertLikeUpdate(isLiked: Bool) {
        isUpdatingLike = false
        updateFavoriteButton(isLiked: isLiked)
    }

    private func updateFavoriteButton(isLiked: Bool) {
        favoriteButtonView.setTintColor(isLiked ? .ypRedUniversal : .white)
    }
}

// MARK: - Action

extension MyNftCell {
    private func handleFavoriteButtonTap() {
        guard let nft, !isUpdatingLike else { return }

        let isLiked = favoriteButtonView.tintColor == .ypRedUniversal
        updateFavoriteButton(isLiked: !isLiked)
        isUpdatingLike = true
        onLikeButtonTap?(nft)
    }
}
