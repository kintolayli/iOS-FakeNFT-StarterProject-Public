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
        label.text = "Title"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = Asset.ypBlack.color
        return label
    }()

    private let cellStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
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

    public override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }

    public override func prepareForReuse() {
        super.prepareForReuse( )
    }

    func updateCell(titleLabel: String, titleImage: UIImage) {
        DispatchQueue.main.async {
            self.cellTitleLabel.text = titleLabel.capitalized
            self.cellTitleImage.image = titleImage
        }
    }

    private func setupUI() {

        [cellTitleImage, cellTitleLabel].forEach {
            cellStackView.addArrangedSubview($0)
        }

        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellStackView)

        NSLayoutConstraint.activate( [
            cellStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -13),
            cellStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
        ])
    }
}
