//
//  CartTableViewCell.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 17.12.2024.
//

protocol CartTableViewCellDelegate: AnyObject {
    func removeItem(_ nftId: String)
}

import UIKit

final class CartTableViewCell: UITableViewCell {
    weak var delegate: CartTableViewCellDelegate?
    static let identifier = "CartTableCell"
    
    var item: CartItem? {
        didSet {
            nftTitleLabel.text = item?.name ?? ""
            nftPriceLabel.text = "\(item?.price ?? 0) ETH"
            nftImageView.kf.setImage(with: URL(string: item?.imageUrl ?? ""))
            setNftRating(stackView: starsStackView, rating: item?.rating ?? 0)
            
        }
    }
    
    private let nftImageView = UIImageView()
    private let removeButton = UIButton()
    
    private let nftTitleLabel = UILabel()
    private let nftRatingView = UIView()
    private let nftPriceLabel = UILabel()
    
    private let priceStackView = UIStackView()
    private let nftInfoStackView = UIStackView()
    private let starsStackView = UIStackView()
    
    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(resource: .ypWhite)
        setupNftImageView()
        setupPriceStackView()
        setupNftInfoStackView()
        setupRemoveButton()
    }
    
    func setupNftImageView() {
        nftImageView.kf.indicatorType = .activity
        nftImageView.kf.setImage(with: URL(string: item?.imageUrl ?? ""))
        
        nftImageView.layer.cornerRadius = 12
        nftImageView.clipsToBounds = true
        
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nftImageView)
        
        NSLayoutConstraint.activate([
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        ])
    }
    
    private func setupPriceStackView() {
        priceStackView.axis = .vertical
        priceStackView.spacing = 2
        
        let headerLabel = UILabel()
        headerLabel.text = "Цена"
        headerLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        nftPriceLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        nftPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceStackView.translatesAutoresizingMaskIntoConstraints = false
        
        priceStackView.addArrangedSubview(headerLabel)
        priceStackView.addArrangedSubview(nftPriceLabel)
        contentView.addSubview(priceStackView)
        
        NSLayoutConstraint.activate([
            priceStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            priceStackView.bottomAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setNftRating(stackView: UIStackView, rating: Int) {
        for (index, item) in stackView.arrangedSubviews.enumerated() {
            if index < rating {
                item.tintColor = UIColor(resource: .ypYellow)
            } else {
                item.tintColor = UIColor(resource: .ypLightGrey)
            }
        }
    }
    
    private func setupNftInfoStackView() {
        nftInfoStackView.axis = .vertical
        nftInfoStackView.spacing = 4
        nftInfoStackView.alignment = .leading
        
        nftTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        
        starsStackView.axis = .horizontal
        starsStackView.spacing = 2
        
        for _ in 0...5 {
            starsStackView.addArrangedSubview(UIImageView(image: UIImage(resource: .star)))
        }
        
        setNftRating(stackView: starsStackView, rating: 2)

        
        nftTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        nftInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        starsStackView.translatesAutoresizingMaskIntoConstraints = false

        nftInfoStackView.addArrangedSubview(nftTitleLabel)
        nftInfoStackView.addArrangedSubview(starsStackView)
        contentView.addSubview(nftInfoStackView)
        
        NSLayoutConstraint.activate([
            nftInfoStackView.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 20),
            nftInfoStackView.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 8)
        ])
    }
    
    private func setupRemoveButton() {
        let removeImage = UIImage(resource: .cartDelete)
        removeButton.setImage(removeImage, for: .normal)
        removeButton.tintColor = UIColor(resource: .ypBlack)
        
        removeButton.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
        
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func didTapRemoveButton() {
        delegate?.removeItem(item?.nftId ?? "")
    }
}


