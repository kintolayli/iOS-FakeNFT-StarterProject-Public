//
//  NFTCardTableViewCell.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 13.01.2025.
//

import UIKit


final class NFTCardTableViewCell: UITableViewCell {
    static let reuseIdentifier = "NFTCardTableViewCell"
    weak var delegate: NFTCardViewControllerProtocol?

    private lazy var cryptoTitleImage: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius6
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var cryptoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.text = "..."
        label.textColor = Asset.ypBlack.color
        return label
    }()

    private lazy var cryptoPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption1
        label.text = "..."
        label.textColor = Asset.ypBlack.color
        return label
    }()

    private lazy var stackView1: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cryptoTitleLabel, cryptoPriceLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fillEqually

        return stackView
    }()

    private lazy var nftPriceLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.textColor = Asset.ypGreen.color
        return label
    }()

    private lazy var stackView2: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [stackView1, spacer, nftPriceLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.distribution = .equalSpacing

        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse( )
    }

    func startShimmering() {
        cryptoTitleImage.addShimmer()
        let grayImage = UIImage.from(color: .segmentInactive, size: CGSize(width: 343, height: 140))
        cryptoTitleImage.image = grayImage

        cryptoTitleLabel.addShimmer()
        cryptoTitleLabel.text = L10n.loading
        cryptoTitleLabel.textColor = .segmentInactive

        cryptoPriceLabel.addShimmer()
        cryptoPriceLabel.text = L10n.loading
        cryptoPriceLabel.textColor = .segmentInactive

        nftPriceLabel.addShimmer()
        nftPriceLabel.text = L10n.loading
        nftPriceLabel.textColor = .segmentInactive
    }

    func stopShimmering() {
        cryptoTitleImage.removeShimmer()

        cryptoTitleLabel.removeShimmer()
        cryptoTitleLabel.textColor = Asset.ypBlack.color

        cryptoPriceLabel.removeShimmer()
        cryptoPriceLabel.textColor = Asset.ypBlack.color

        nftPriceLabel.removeShimmer()
        nftPriceLabel.textColor = Asset.ypGreen.color
    }

    func updateCell(cryptoTitleImage: UIImage, cryptoTitleLabel: String, cryptoPriceLabel: String, nftPriceLabel: String) {
        DispatchQueue.main.async {
            self.cryptoTitleImage.image = cryptoTitleImage
            self.cryptoTitleLabel.text = cryptoTitleLabel
            self.cryptoPriceLabel.text = cryptoPriceLabel
            self.nftPriceLabel.text = nftPriceLabel
        }
    }

    private func setupUI() {
        [cryptoTitleImage, stackView2].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        contentView.backgroundColor = Asset.ypLightGrey.color

        NSLayoutConstraint.activate( [
            cryptoTitleImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cryptoTitleImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            cryptoTitleImage.widthAnchor.constraint(equalToConstant: 32),
            cryptoTitleImage.heightAnchor.constraint(equalTo: cryptoTitleImage.widthAnchor),

            stackView2.leadingAnchor.constraint(equalTo: cryptoTitleImage.trailingAnchor, constant: 10),
            stackView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView2.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}

