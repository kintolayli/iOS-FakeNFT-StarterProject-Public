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
    func showAlert(with: AlertModel)
    func likeButtonDidTap(_ cell: NFTCollectionViewCell)
    func cartButtonDidTap(_ cell: NFTCollectionViewCell)
}

class NFTCollectionViewController: UIViewController, NFTCollectionViewControllerProtocol {
    private let currentCollection: NFTCollectionModel
    private var profileId = 1
    var presenter: NFTCollectionPresenterProtocol

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.cornerRadius
        view.contentMode = .scaleAspectFit
        view.kf.indicatorType = .activity
        return view
    }()

    private lazy var collectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.text = currentCollection.name.capitalized
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionAuthorLabel: UILabel = {
        let label = UILabel()
        label.font = .caption2
        label.text = L10n.NFTCollectionViewController.collectionAuthorLabel
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()

    private lazy var collectionAuthorLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(currentCollection.author.capitalized, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .caption1
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
        label.font = .caption2
        label.text = currentCollection.description.capitalized
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

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var params: GeometricParams = {
        let params = GeometricParams(cellCount: 3, leftInset: 0, rightInset: 0, cellSpacing: 9)
        return params
    }()

    init(
        currentCollection: NFTCollectionModel,
         presenter: NFTCollectionPresenterProtocol
    ) {
        self.currentCollection = currentCollection
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        presenter.viewController = self
        presenter.loadLikes(profileId: profileId)
        presenter.loadNFTsInCart(profileId: profileId)
        presenter.loadInitialData(nftIds: currentCollection.nfts)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

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
            contentView.heightAnchor.constraint(equalToConstant: 900 + CGFloat(Int(ceil(Double(presenter.nfts.count) / 3.0))) * 200),

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
        collectionView.dataSource = self

        collectionView.register(NFTCollectionViewCell.self, forCellWithReuseIdentifier: NFTCollectionViewCell.reuseIdentifier)
        collectionView.scrollIndicatorInsets = collectionView.contentInset

        scrollView.contentInset = UIEdgeInsets(top: -100, left: 0, bottom: 0, right: 0)

        let coverImageView = loadKingfisherImage(url: currentCollection.cover)
        imageView.image = coverImageView
    }

    @objc
    func authorLinkButtonDidTap() {
        let webViewViewController = WebViewViewController()
        let webViewPresenter = WebViewPresenter(stringUrl: "https://practicum.yandex.ru/ios-developer/")
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController

        navigationController?.pushViewController(webViewViewController, animated: true)
    }

    func loadKingfisherImage(url: URL) -> UIImage {
        UIBlockingProgressHUD.show()
        let processor = RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius)

        let imageView = UIImageView()
        imageView.kf.setImage(
            with: url,
            options: [.processor(processor), .transition(.fade(0.3))],
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

    func updateView() {
        collectionView.reloadData()
    }
}

extension NFTCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.nfts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCollectionViewCell.reuseIdentifier, for: indexPath) as? NFTCollectionViewCell else { return UICollectionViewCell() }

        cell.delegate = self
        cell.layer.cornerRadius = Constants.cornerRadius

        let newCell = presenter.nfts[indexPath.row]
        let cellImageView = loadKingfisherImage(url: newCell.images[0])

        cell.updateCell(
            cell: newCell,
            image: cellImageView,
            profileLikes: presenter.likes,
            nftsInCart: presenter.nftsInCart
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nftViewController = NFTCardViewController(currentNFT: presenter.nfts[indexPath.row])
        navigationController?.pushViewController(nftViewController, animated: true)
    }
}

extension NFTCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 192)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
}


extension NFTCollectionViewController {
    func showAlert(with model: AlertModel) {
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}

extension NFTCollectionViewController {
    func likeButtonDidTap(_ cell: NFTCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        let nftId = presenter.nfts[indexPath.row].id
        presenter.sendLike(profileId: profileId, nftId: nftId)
    }

    func cartButtonDidTap(_ cell: NFTCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell)  else { return }
        let nftId = presenter.nfts[indexPath.row].id
        presenter.sendNFTToCart(profileId: profileId, nftId: nftId)
    }
}
