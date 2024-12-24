//
//  CollectionViewController.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 24.12.2024.
//

import UIKit

class NFTCollectionViewController: UIViewController {
    private let currentCollection: String

    private lazy var collectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    init(currentCollection: String) {
        self.currentCollection = currentCollection
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(collectionLabel)
        collectionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
