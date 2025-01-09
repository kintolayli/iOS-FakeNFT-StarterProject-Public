//
//  NFTCardViewController.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 07.01.2025.
//

import UIKit

class NFTCardViewController: UIViewController {
    private let currentNFT: NFTModel

    init(currentNFT: NFTModel) {
        self.currentNFT = currentNFT

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var nftNameLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.text = currentNFT.name
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var nftIdLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.text = currentNFT.id.uuidString
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        [nftNameLabel, nftIdLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            nftNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nftNameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            nftIdLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nftIdLabel.topAnchor.constraint(equalTo: nftNameLabel.bottomAnchor, constant: 20)
        ])
    }
}
