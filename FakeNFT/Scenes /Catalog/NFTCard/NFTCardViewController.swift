//
//  NFTCardViewController.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 07.01.2025.
//

import UIKit
import Kingfisher

protocol NFTCardViewControllerProtocol: AnyObject {
    var presenter: NFTCardPresenterProtocol { get set }
    func displayCells(_ cellModels: [NftDetailCellModel])
    func showAlert(with: AlertModel)
    func updateView()
    func reloadData()
}

class NFTCardViewController: UIViewController, NFTCollectionViewControllerProtocol {
    var presenter: NFTCardPresenterProtocol
    let servicesAssembly: ServicesAssembly
    
    private var animatingButtons: Set<UIButton> = []
    
    init(presenter: NFTCardPresenterProtocol, servicesAssembly: ServicesAssembly) {
        self.presenter = presenter
        self.servicesAssembly = servicesAssembly
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var cellModels: [NftDetailCellModel] = []
    
    private lazy var params: GeometricParams = {
        let params = GeometricParams(cellCount: 3, leftInset: 0, rightInset: 0, topInset: 10, bottomInset: 10, cellSpacing: 9)
        return params
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var collectionViewTop: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(NftImageCollectionViewTopCell.self, forCellWithReuseIdentifier: NftImageCollectionViewTopCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        collectionView.layer.cornerRadius = Constants.cornerRadius40
        collectionView.clipsToBounds = true
        
        return collectionView
    }()
    
    private lazy var pageControl = LinePageControl()
    
    internal lazy var activityIndicator = UIActivityIndicatorView()
    
    private lazy var likeButtonPrimary: UIButton = {
        let button = UIButton(type: .system)
        
        let heartImage = UIImage(systemName: "heart.fill")
        button.setImage(heartImage, for: .normal)
        button.tintColor = Asset.ypWhite.color
        
        button.layer.shadowColor = Asset.ypBlack.color.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowRadius = 5
        
        button.backgroundColor = .clear
        button.adjustsImageWhenHighlighted = true
        
        return button
    }()
    
    private lazy var nftNameLabel: UILabel = {
        let label = UILabel()
        label.font = .bold22
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stars = (0..<5).map { _ -> UIImageView in
            let imageView = UIImageView()
            imageView.image = Asset.star.image.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = Asset.ypLightGrey.color
            return imageView
        }
        
        let stackView = UIStackView(arrangedSubviews: stars)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 2
        stackView.alignment = .leading
        
        return stackView
    }()
    
    private lazy var collectionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .bold17
        label.textColor = .label
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var stackView1: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [nftNameLabel, ratingStackView, spacer, collectionNameLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var priceNameLabel: UILabel = {
        let label = UILabel()
        label.font = .regular15
        label.textColor = .label
        label.textAlignment = .center
        
        label.text = L10n.NFTCardViewController.priceNameLabel
        
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = .bold17
        label.textColor = .label
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var stackView2: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [priceNameLabel, priceLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var addToCartButtonPrimary: UIButton = {
        let button = UIButton(type: .system)
        
        button.tintColor = Asset.ypWhite.color
        button.setTitle(L10n.NFTCardViewController.addToCartButton, for: .normal)
        button.titleLabel?.font = .bold17
        
        button.backgroundColor = Asset.ypBlack.color
        button.adjustsImageWhenHighlighted = true
        
        button.layer.cornerRadius = Constants.cornerRadius16
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(NFTCardTableViewCell.self, forCellReuseIdentifier: NFTCardTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        
        tableView.layer.cornerRadius = Constants.cornerRadius12
        tableView.layer.masksToBounds = true
        
        return tableView
    }()
    
    private lazy var sellerButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.tintColor = Asset.ypBlack.color
        button.setTitle(L10n.NFTCardViewController.sellerButton, for: .normal)
        button.titleLabel?.font = .regular15
        
        button.backgroundColor = Asset.ypWhite.color
        button.adjustsImageWhenHighlighted = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Asset.ypBlack.color.cgColor
        
        button.layer.cornerRadius = Constants.cornerRadius16
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var collectionViewBottom: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(NFTCollectionViewCell.self, forCellWithReuseIdentifier: NFTCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialData()
    }
    
    private func loadInitialData() {
        UIBlockingProgressHUD.show()
        tableView.addShimmer()
        
        presenter.loadInitialData { _ in
            UIBlockingProgressHUD.dismiss()
            self.tableView.removeShimmer()
            self.setupUI()
            self.updateView()
        }
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
        
        [
            collectionViewTop,
            pageControl,
            stackView1,
            stackView2,
            addToCartButtonPrimary,
            tableView,
            sellerButton,
            collectionViewBottom
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Asset.ypLightGrey.color
        let heghtTableView = presenter.getCryptoCurrencies().count
        
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
            contentView.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 2.5),
            
            collectionViewTop.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionViewTop.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionViewTop.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewTop.heightAnchor.constraint(equalTo: collectionViewTop.widthAnchor),
            
            pageControl.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: collectionViewTop.bottomAnchor,constant: 12),
            pageControl.heightAnchor.constraint(equalToConstant: 4),
            
            stackView1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView1.topAnchor.constraint(equalTo: collectionViewTop.bottomAnchor, constant: 44),
            
            stackView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView2.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 24),
            stackView2.heightAnchor.constraint(equalToConstant: 44),
            
            addToCartButtonPrimary.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addToCartButtonPrimary.widthAnchor.constraint(equalToConstant: 240),
            addToCartButtonPrimary.heightAnchor.constraint(equalToConstant: 44),
            addToCartButtonPrimary.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 24),
            
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: addToCartButtonPrimary.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(72 * heghtTableView)),
            
            sellerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sellerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sellerButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            sellerButton.heightAnchor.constraint(equalToConstant: 40),
            
            collectionViewBottom.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionViewBottom.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewBottom.topAnchor.constraint(equalTo: sellerButton.bottomAnchor, constant: 36),
            collectionViewBottom.heightAnchor.constraint(equalToConstant: 200)
        ])
        scrollView.contentInset = UIEdgeInsets(top: -100, left: 0, bottom: 0, right: 0)
        
        likeButtonPrimary.addTarget(self, action: #selector(likeButtonPrimaryDidTap), for: .touchUpInside)
        addToCartButtonPrimary.addTarget(self, action: #selector(addToCartButtonPrimaryDidTap), for: .touchUpInside)
        sellerButton.addTarget(self, action: #selector(sellerButtonDidTap), for: .touchUpInside)
        
        collectionViewBottom.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButtonPrimary)
    }
    
    func updateView() {
        let currentNFT = presenter.getCurrentNFT()
        let currentCollectionTitle = presenter.getCurrentCollectionTitle()
        
        let cellModels = currentNFT.images.map { NftDetailCellModel(url: $0) }
        displayCells(cellModels)
        
        setRating(ratingCount: currentNFT.rating)
        
        priceLabel.text = "\(currentNFT.price) ETH"
        collectionNameLabel.text = currentCollectionTitle
        nftNameLabel.text = currentNFT.name

        updateLikeButtonPrimary()
        updateAddToCardButtonPrimary()
        reloadData()
    }
    
    private func setRating(ratingCount: Int) {
        for item in 0..<ratingCount {
            ratingStackView.arrangedSubviews[item].tintColor = Asset.ypYellow.color
        }
    }

    private func updateLikeButtonPrimary() {
        let cellData = presenter.getCellData()
        let currentNFT = presenter.getCurrentNFT()

        if cellData.likes.contains(currentNFT.id) {
            likeButtonPrimary.tintColor = Asset.ypRed.color
        } else {
            likeButtonPrimary.tintColor = Asset.ypWhite.color
        }
    }

    private func updateAddToCardButtonPrimary() {
        let cellData = presenter.getCellData()
        let currentNFT = presenter.getCurrentNFT()
        
        if cellData.nftsInCart.contains(currentNFT.id) {
            addToCartButtonPrimary.setTitle(L10n.NFTCardViewController.inCartButton, for: .normal)
            addToCartButtonPrimary.backgroundColor = Asset.ypWhite.color
            addToCartButtonPrimary.tintColor = Asset.ypBlack.color
            addToCartButtonPrimary.layer.borderWidth = 1
            addToCartButtonPrimary.layer.borderColor = Asset.ypBlack.color.cgColor
        } else {
            addToCartButtonPrimary.setTitle(L10n.NFTCardViewController.addToCartButton, for: .normal)
            addToCartButtonPrimary.backgroundColor = Asset.ypBlack.color
            addToCartButtonPrimary.tintColor = Asset.ypWhite.color
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}


// MARK: - NFTCardViewController

extension NFTCardViewController: NftDetailView {
    func displayCells(_ cellModels: [NftDetailCellModel]) {
        self.cellModels = cellModels
        collectionViewTop.reloadData()
        pageControl.numberOfItems = cellModels.count
    }
}

// MARK: - UICollectionViewDelegate

extension NFTCardViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource

extension NFTCardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewTop {
            return cellModels.count
        } else {
            let nfts = presenter.getNfts()
            return nfts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewTop {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NftImageCollectionViewTopCell.reuseIdentifier, for: indexPath) as? NftImageCollectionViewTopCell else { return UICollectionViewCell() }
            
            let cellModel = cellModels[indexPath.row]
            cell.configure(with: cellModel)
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTCollectionViewCell.reuseIdentifier, for: indexPath) as? NFTCollectionViewCell else { return UICollectionViewCell() }

            cell.delegate = self

            let cellData = presenter.getCellData()
            let nft = presenter.getNft(indexPath: indexPath)
            
            let NFTCollectionCoverImageURL = nft.images[0]
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
                        cell: nft,
                        image: nftImage,
                        profileLikes: cellData.likes,
                        nftsInCart: cellData.nftsInCart
                    )
                case .failure(let error):
                    let logMessage =
        """
        [\(String(describing: self)).\(#function)]:
        \(NFTCollectionPresenterError.fetchImageError) - Ошибка получения изображения ячейки таблицы, \(error.localizedDescription)
        """
                    print(logMessage)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewTop {
            let currentNft = presenter.getCurrentNFT()
            let presenter = NftDetailPresenterImplAlt(currentNft: currentNft)
            let nftDetailViewController = NftDetailViewController(presenter: presenter)
            presenter.view = nftDetailViewController
            present(nftDetailViewController, animated: true)
        } else {
            let currentNft = presenter.getNft(indexPath: indexPath)
            let currentCollectionTitle = presenter.getCurrentCollectionTitle()
            let nfts = presenter.getNfts()
            let newPresenter = NFTCardPresenter(currentNFT: currentNft, currentCollectionTitle: currentCollectionTitle, nfts: nfts)
            presenter = newPresenter
            loadInitialData()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NFTCardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionViewTop {
            return collectionView.bounds.size
        } else {
            let availableWidth = collectionView.frame.width - params.paddingWidth - 40
            let cellWidth = availableWidth / CGFloat(params.cellCount)
            return CGSize(width: cellWidth, height: Constants.NFTCollectionViewControllerCellHeight)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let selectedItem = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.selectedItem = selectedItem
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionViewBottom {
            return params.cellSpacing
        } else {
            return CGFloat()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionViewBottom {
            return params.cellSpacing
        } else {
            return CGFloat()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == collectionViewBottom {
            return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
        } else {
            return UIEdgeInsets()
        }
    }
}

// MARK: - UITableViewDelegate

extension NFTCardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.nftCardTableViewCellHeight
    }
}

// MARK: - UITableViewDataSource

extension NFTCardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = presenter.getCryptoCurrencies().count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NFTCardTableViewCell.reuseIdentifier, for: indexPath) as? NFTCardTableViewCell else { return UITableViewCell() }
        
        let currentCurrency = presenter.getCryptoCurrency(indexPath: indexPath)
        let currentCurrencyId = Int(currentCurrency.id) ?? 7
        
        let currentCurrencyPrice = presenter.getСurrentCurrencyPrice(id: currentCurrencyId)
        var formattedcurrentCurrencyPrice: String
        if [0, 1, 2].contains(currentCurrencyId) {
            formattedcurrentCurrencyPrice = String(format: "%.6f", currentCurrencyPrice)
        } else {
            formattedcurrentCurrencyPrice = String(format: "%.2f", currentCurrencyPrice)
        }
        
        let currentNftPriceInEth = presenter.getCurrentNFT().price
        let priceInOtherCurrency = presenter.calculatePriceInOtherCurrency(priceInEth: currentNftPriceInEth, currencyId: currentCurrencyId)
        let formattedPriceInOtherCurrency = String(format: "%.2f", priceInOtherCurrency)
        
        let cryptoTitleImageURL = currentCurrency.image
        let imageView = UIImageView()
        let processor = RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius6)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: cryptoTitleImageURL,
                              placeholder: .none,
                              options: [.processor(processor)]) { result in
            switch result {
            case .success:
                
                guard let cryptoTitleImage = imageView.image else { return }
                
                let cryptoTitleLabel = "\(currentCurrency.title.components(separatedBy: "_").joined(separator: " ")) (\(currentCurrency.name.uppercased()))"
                
                cell.updateCell(cryptoTitleImage: cryptoTitleImage, cryptoTitleLabel: cryptoTitleLabel, cryptoPriceLabel: "$\(formattedcurrentCurrencyPrice)", nftPriceLabel: "\(formattedPriceInOtherCurrency) \(currentCurrency.name)")
            case .failure(let error):
                let logMessage =
            """
            [\(String(describing: self)).\(#function)]:
            \(NFTCardPresenterError.fetchCellImageError) - Ошибка получения изображения ячейки таблицы, \(error.localizedDescription)
            """
                print(logMessage)
            }
        }
        
        return cell
    }
}

// MARK: - NFTCardViewController Buttons Methods

extension NFTCardViewController {
    @objc
    private func likeButtonPrimaryDidTap() {
        UIBlockingProgressHUD.show()
        startAnimatingButton(likeButtonPrimary)
        
        let nftId = presenter.getCurrentNFT().id
        
        presenter.sendLike(nftId: nftId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIBlockingProgressHUD.dismiss()
                self.stopAnimatingButton(self.likeButtonPrimary)
                self.updateLikeButtonPrimary()
                self.collectionViewBottom.reloadData()
            }
        }
    }
    
    @objc
    private func addToCartButtonPrimaryDidTap() {
        UIBlockingProgressHUD.show()
        startAnimatingButton(addToCartButtonPrimary)
        
        let nftId = presenter.getCurrentNFT().id
        
        presenter.sendNFTToCart(nftId: nftId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIBlockingProgressHUD.dismiss()
                self.stopAnimatingButton(self.addToCartButtonPrimary)
                self.updateAddToCardButtonPrimary()
                self.collectionViewBottom.reloadData()
            }
        }
    }
    
    @objc
    private func sellerButtonDidTap() {
        let webViewViewController = WebViewViewController()
        let webViewPresenter = WebViewPresenter(stringUrl: Constants.practiicunIosDeveloperUrl)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    private func animateButtonIndefinitely(_ button: UIButton) {
        guard animatingButtons.contains(button) else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            button.alpha = 0.75
            button.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.25, animations: {
                button.alpha = 1.0
                button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { _ in
                self.animateButtonIndefinitely(button)
            }
        }
    }
    
    func startAnimatingButton(_ button: UIButton) {
        animatingButtons.insert(button)
        animateButtonIndefinitely(button)
    }
    
    func stopAnimatingButton(_ button: UIButton) {
        animatingButtons.remove(button)
        button.layer.removeAllAnimations()
        button.alpha = 1.0
        button.transform = .identity
    }
}

// MARK: - Show Alert

extension NFTCardViewController {
    func showAlert(with model: AlertModel) {
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}

// MARK: - CollectionViewBottom Buttons Methods

extension NFTCardViewController {
    func likeButtonDidTap(_ cell: NFTCollectionViewCell) {
        UIBlockingProgressHUD.show()
        cell.animateLikeButton()

        guard let indexPath = collectionViewBottom.indexPath(for: cell)  else { return }
        let nftId = presenter.getNft(indexPath: indexPath).id

        presenter.sendLike(nftId: nftId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cell.removeAnimateLikeButton()
                self.collectionViewBottom.reloadData()
                self.updateLikeButtonPrimary()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    func cartButtonDidTap(_ cell: NFTCollectionViewCell) {
        UIBlockingProgressHUD.show()
        cell.animateCartButton()

        guard let indexPath = collectionViewBottom.indexPath(for: cell)  else { return }
        let nftId = presenter.getNft(indexPath: indexPath).id

        presenter.sendNFTToCart(nftId: nftId) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cell.removeAnimateCartButton()
                self.collectionViewBottom.reloadData()
                self.updateAddToCardButtonPrimary()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
