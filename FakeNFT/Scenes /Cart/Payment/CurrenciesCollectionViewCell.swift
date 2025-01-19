//
//  CurrenciesCollectionViewCell.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 24.12.2024.
//

import UIKit

final class CurrenciesCollectionViewCell: UICollectionViewCell {
    static let identifier = "CurrenciesCollectionCell"
    
    var currency: Currency? {
        didSet {
            currencyImageView.kf.setImage(with: URL(string: currency?.image ?? ""))
            currencyTitleLabel.text = currency?.title ?? ""
            currencyNameLabel.text = currency?.name ?? ""
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            cellView.layer.borderWidth = isPicked == true ? 1 : 0
        }
    }
    
    let cellView = UIView()
    let currencyImageView = UIImageView()
    let currencyInfoStackView = UIStackView()
    let currencyTitleLabel = UILabel()
    let currencyNameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
        setupCurrencyImageView()
        setupCurrencyInfoStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupCellView() {
        cellView.backgroundColor = Asset.ypLightGrey.color
        cellView.layer.cornerRadius = 16
        cellView.layer.borderWidth = 0
        cellView.layer.borderColor = Asset.ypBlack.color.cgColor
        
        cellView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cellView)
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    private func setupCurrencyImageView() {
        currencyImageView.kf.indicatorType = .activity
        currencyImageView.layer.cornerRadius = 6
        currencyImageView.clipsToBounds = true
        currencyImageView.backgroundColor = Asset.ypBlackUniversal.color
        
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        
        cellView.addSubview(currencyImageView)
        
        NSLayoutConstraint.activate([
            currencyImageView.widthAnchor.constraint(equalToConstant: 36),
            currencyImageView.heightAnchor.constraint(equalToConstant: 36),
            currencyImageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            currencyImageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ])
    }
    
    private func setupCurrencyInfoStackView() {
        currencyInfoStackView.axis = .vertical
        currencyInfoStackView.spacing = 0
        
        currencyTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        currencyTitleLabel.textColor = Asset.ypBlack.color
        
        currencyNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        currencyNameLabel.textColor = Asset.ypGreen.color
        
        currencyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        currencyInfoStackView.addArrangedSubview(currencyTitleLabel)
        currencyInfoStackView.addArrangedSubview(currencyNameLabel)
        cellView.addSubview(currencyInfoStackView)
        
        NSLayoutConstraint.activate([
            currencyInfoStackView.leadingAnchor.constraint(equalTo: currencyImageView.trailingAnchor, constant: 4),
            currencyInfoStackView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ])
    }
}
