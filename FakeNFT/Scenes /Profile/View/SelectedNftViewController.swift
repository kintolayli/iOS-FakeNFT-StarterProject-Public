//
//  SelectedNftViewController.swift
//  FakeNFT
//
//  Created by  Admin on 28.12.2024.
//

import UIKit

protocol SelectedNftProtocol: AnyObject {
    func reloadData()
    func reloadItem(at index: Int)
    func deleteItem(at index: Int)
    func cellForItem(at index: Int) -> NFTCellProtocol?
}

final class SelectedNftViewController: UIViewController {

    private let presenter: SelectedNftPresenterProtocol
    private let helper = MyNftHelper()
    private var shimmerViews: [ShimmerView] = []

    private let params = GeometricParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 7
    )

    private lazy var placeholderView: Placeholder = {
        let placeholder = Placeholder(text: LocalizationKey.profSelectedNftPlaceholder.localized())
        placeholder.isHidden = true
        return placeholder
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectedNftCell.self)
        collectionView.register(ShimmerCollectionViewCell.self)
        return collectionView
    }()

    // MARK: - Init

    init(presenter: SelectedNftPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupNavigationBar()
        setupUI()
        checkForData()
        presenter.viewDidLoad()
    }

    private func setupNavigationBar() {
        title = LocalizationKey.profSelectedNft.localized()

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .ypBlack

        navigationItem.leftBarButtonItem = backButton
    }
}

// MARK: - Layout

extension SelectedNftViewController {

    private func setupUI() {
        [collectionView, placeholderView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        collectionView.constraintEdges(to: view)
        placeholderView.constraintCenters(to: view)
    }
}

// MARK: - Actions

extension SelectedNftViewController {
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension SelectedNftViewController: UICollectionViewDelegate {}

// MARK: - UICollectionViewDataSource

extension SelectedNftViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.isLoading ? shimmerViews.count : presenter.nfts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !presenter.isLoading else {
            let cell: ShimmerCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        }

        let cell: SelectedNftCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let nft = presenter.nfts[indexPath.row]
        let price = String(nft.price)
        let isLiked = presenter.isLiked(nft: nft)
        let coins = "ETH"
        presenter.configureCell(cell, with: nft, isLiked: isLiked, priceText: price, currencyText: coins)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SelectedNftViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 20,
            left: params.leftInset,
            bottom: 20,
            right: params.rightInset
        )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let collectionViewWidth = collectionView.bounds.width
        let availableWidth = collectionViewWidth - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        let cellHeight: CGFloat = cellWidth * 0.5

        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
}

// MARK: - Load

extension SelectedNftViewController {

    private func checkForData() {
        if presenter.isLoading {
            placeholderView.isHidden = true
            collectionView.isHidden = false
        } else {
            let hasData = presenter.nfts.count > 0
            placeholderView.isHidden = hasData
            collectionView.isHidden = !hasData
        }
    }

    private func startLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presenter.isLoading = true
            self.shimmerViews = self.helper.createShimmerViews(count: 14)
            self.collectionView.reloadData()
        }
    }

    private func stopLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presenter.isLoading = false
            self.shimmerViews.removeAll()
            self.collectionView.reloadData()
        }
    }
}

// MARK: - MyNftProtocol

extension SelectedNftViewController: SelectedNftProtocol {
    func reloadData() {
        if presenter.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
        collectionView.reloadData()
        checkForData()
    }

    func reloadItem(at index: Int) {
        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    func deleteItem(at index: Int) {
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    func cellForItem(at index: Int) -> NFTCellProtocol? {
        let indexPath = IndexPath(item: index, section: 0)
        return collectionView.cellForItem(at: indexPath) as? NFTCellProtocol
    }
}
