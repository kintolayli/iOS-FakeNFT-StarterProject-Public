//
//  CollectionViewController.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 24.12.2024.
//

import UIKit
import Kingfisher


protocol NFTCollectionViewControllerProtocol: AnyObject {
    func updateView()
    func reloadData()
    func showAlert(with: AlertModel)
    func likeButtonDidTap(_ cell: NFTCollectionViewCell)
    func cartButtonDidTap(_ cell: NFTCollectionViewCell)
}

class NFTCollectionViewController: UIViewController, NFTCollectionViewControllerProtocol {
    var presenter: NFTCollectionPresenterProtocol
    private let servicesAssembly: ServicesAssembly

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius12
        view.contentMode = .scaleAspectFit
        view.kf.indicatorType = .activity
        return view
    }()

    private lazy var collectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold22
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionAuthorLabel: UILabel = {
        let label = UILabel()
        label.font = .regular13
        label.text = L10n.NFTCollectionViewController.collectionAuthorLabel
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()

    private lazy var collectionAuthorLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .regular15
        button.contentHorizontalAlignment = .leading
        button.contentVerticalAlignment = .bottom
        button.addTarget(self, action: #selector(authorLinkButtonDidTap), for: .touchUpInside)
        return button
    }()

    private lazy var authorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [collectionAuthorLabel, collectionAuthorLinkButton])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .firstBaseline
        return stackView
    }()

    private lazy var collectionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular13
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()

    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authorStackView, collectionDescriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<LoadingSectionModel, NftModel> = {
        UICollectionViewDiffableDataSource<LoadingSectionModel, NftModel>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NFTCollectionViewCell.reuseIdentifier, for: indexPath
            ) as? NFTCollectionViewCell else {
                return UICollectionViewCell()
            }

            switch LoadingSectionModel(rawValue: indexPath.section) {
            case .loading:
                cell.startShimmering()
            case .data:
                cell.stopShimmering()
            default:
                break
            }

            self.configureCell(cell, itemIdentifier)
            return cell
        }
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var params: GeometricParams = {
        let params = GeometricParams(cellCount: 3, leftInset: 0, rightInset: 0, topInset: 10, bottomInset: 10, cellSpacing: 9)
        return params
    }()

    init(presenter: NFTCollectionPresenterProtocol, collection: NFTCollectionModel, servicesAssembly: ServicesAssembly) {
        self.presenter = presenter
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)

        collectionTitleLabel.text = collection.name.capitalized
        collectionAuthorLinkButton.setTitle(collection.author.capitalized, for: .normal)
        collectionDescriptionLabel.text = collection.description.capitalized

        let coverImageView = loadKingfisherImage(url: collection.cover)
        imageView.image = coverImageView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.loadLikes()
        presenter.loadNFTsInCart()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter.viewController = self

        UIBlockingProgressHUD.show()
        presenter.loadInitialData { _ in
            UIBlockingProgressHUD.dismiss()
        }
        updateView()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        let nfts = presenter.getNfts()
        let scrollViewAddSpace = CGFloat(Int(ceil(Double(nfts.count) / 3.0))) * 200

        [scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }

        [imageView, collectionTitleLabel, labelStackView, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 900 + scrollViewAddSpace),

            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: Constants.imageAspectMultiplier),

            collectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionTitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),

            labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelStackView.topAnchor.constraint(equalTo: collectionTitleLabel.bottomAnchor, constant: 16),

            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        collectionView.delegate = self

        collectionView.register(NFTCollectionViewCell.self, forCellWithReuseIdentifier: NFTCollectionViewCell.reuseIdentifier)
        collectionView.scrollIndicatorInsets = collectionView.contentInset

        scrollView.contentInset = UIEdgeInsets(top: -100, left: 0, bottom: 0, right: 0)
    }

    @objc
    func authorLinkButtonDidTap() {
        let webViewViewController = WebViewViewController()
        let webViewPresenter = WebViewPresenter(stringUrl: Constants.practiicunIosDeveloperUrl)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController

        navigationController?.pushViewController(webViewViewController, animated: true)
    }

    func loadKingfisherImage(url: URL) -> UIImage {
        UIBlockingProgressHUD.show()
        let processor = RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius12)

        let imageView = UIImageView()
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage.from(
                color: Asset.ypLightGrey.color,
                size: CGSize(
                    width: Constants.collectionTitleImagePlaceholderWidth,
                    height: Constants.collectionTitleImagePlaceholderHeight
                )
            ),
            options: [.processor(processor), .transition(.fade(Constants.animationDuration))],
            completionHandler: { result in
                switch result {
                case .success(_):
                    UIBlockingProgressHUD.dismiss()
                case .failure(_):
                    UIBlockingProgressHUD.dismiss()
                }
            }
        )
        return imageView.image ?? UIImage.from(color: Asset.ypLightGrey.color)
    }

    private func applySnapshot(animatingDifferences: Bool = true, completion: @escaping (Bool) -> Void) {
        var snapshot = NSDiffableDataSourceSnapshot<LoadingSectionModel, NftModel>()

        let isLoading = presenter.getLoadingStatus()

        if isLoading {
            snapshot.appendSections([.loading])

            let placeholders = presenter.createPlaceholderNFTs()
            snapshot.appendItems(placeholders, toSection: .loading)
        } else {
            snapshot.deleteSections([.loading])
            snapshot.appendSections([.data])

            let items = presenter.createNFTs()
            snapshot.appendItems(items, toSection: .data)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        completion(true)
    }

    func updateView() {
        UIBlockingProgressHUD.show()
        applySnapshot { _ in
            UIBlockingProgressHUD.dismiss()
        }
    }

    func reloadData() {
        collectionView.reloadData()
    }
}

extension NFTCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getNfts().count
    }

    func configureCell(_ cell: NFTCollectionViewCell, _ item: NftModel) {
        cell.backgroundColor = .clear

        let cellData = presenter.getCellData()
        let isLoading = presenter.getLoadingStatus()

        if isLoading {
            cell.startShimmering()
        } else {
            cell.stopShimmering()

            let NFTCollectionCoverImageURL = item.images[0]
            let imageView = UIImageView()
            let processor = RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius12)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: NFTCollectionCoverImageURL,
                                  placeholder: .none,
                                  options: [.processor(processor)]) { result in
                switch result {
                case .success:
                    guard let nftImage = imageView.image else { return }

                    cell.updateCell(
                        cell: item,
                        image: nftImage,
                        profileLikes: cellData.likes,
                        nftsInCart: cellData.nftsInCart
                    )
                    cell.delegate = self
                    cell.layer.cornerRadius = Constants.cornerRadius12

                case .failure(let error):
                    let logMessage =
                """
                [\(String(describing: self)).\(#function)]:
                \(NFTCollectionPresenterError.fetchImageError) - Ошибка получения изображения ячейки таблицы, \(error.localizedDescription)
                """
                    print(logMessage)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentNft = presenter.getNft(indexPath: indexPath)
        let nfts = presenter.getNfts()
        guard let currentCollectionTitle = collectionTitleLabel.text else { return }

        let presenter = NFTCardPresenter(currentNFT: currentNft, currentCollectionTitle: currentCollectionTitle, nfts: nfts)

        let nftViewController = NFTCardViewController(presenter: presenter, servicesAssembly: servicesAssembly)
        navigationController?.pushViewController(nftViewController, animated: true)
    }
}

extension NFTCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: Constants.NFTCollectionViewControllerCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
}


extension NFTCollectionViewController {
    func showAlert(with model: AlertModel) {
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}

extension NFTCollectionViewController {
    func likeButtonDidTap(_ cell: NFTCollectionViewCell) {
        UIBlockingProgressHUD.show()
        cell.animateLikeButton()

        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        let nftId = presenter.getNft(indexPath: indexPath).id

        presenter.sendLike(nftId: nftId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cell.removeAnimateLikeButton()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    func cartButtonDidTap(_ cell: NFTCollectionViewCell) {
        UIBlockingProgressHUD.show()
        cell.animateCartButton()

        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        let nftId = presenter.getNft(indexPath: indexPath).id

        presenter.sendNFTToCart(nftId: nftId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cell.removeAnimateCartButton()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
