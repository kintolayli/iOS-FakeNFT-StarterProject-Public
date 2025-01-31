//
//  MyNftViewController.swift
//  FakeNFT
//
//  Created by  Admin on 26.12.2024.
//

import UIKit

protocol MyNftProtocol: AnyObject {
    func reloadData()
    func reloadRow(at index: Int)
    func cellForRow(at index: Int) -> MyNftCell?
    func showError(message: String)
}

final class MyNftViewController: UIViewController {

    // MARK: - Private Properties

    private var shimmerViews: [ShimmerView] = []
    private let presenter: MyNftPresenterProtocol
    private let helper = MyNftHelper()

    private lazy var placeholderView: Placeholder = {
        let placeholder = Placeholder(text: LocalizationKey.profMyNftPlaceholder.localized())
        placeholder.isHidden = true
        return placeholder
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypWhite
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyNftCell.self)
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Init

    init(presenter: MyNftPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.view = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .nftLikeStatusChanged, object: nil)
    }

    // MARK: - Lyfecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupUI()
        checkForData()
        setupNavigationBar()
        presenter.viewDidLoad()
    }

    // MARK: - Private Methods

    private func checkForData() {
        if presenter.isLoading {
            placeholderView.isHidden = true
            tableView.isHidden = false
        } else {
            let hasData = presenter.nfts.count > 0
            placeholderView.isHidden = hasData
            tableView.isHidden = !hasData
        }
    }

    private func setupNavigationBar() {
        title = LocalizationKey.profMyNft.localized()

        let sortButton = UIBarButtonItem(
            image: UIImage(named: "light"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        [sortButton, backButton].forEach {
            $0.tintColor = .ypBlack
        }

        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = sortButton
    }
}

// MARK: - Layout

extension MyNftViewController {
    private func setupUI() {
        [tableView, placeholderView].forEach {
            view.setupView($0)
        }
        [placeholderView].forEach {
            $0.constraintCenters(to: view)
        }
        tableView.refreshControl = refreshControl
        tableView.constraintEdges(to: view)
    }
}

// MARK: - UITableViewDelegate

extension MyNftViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return presenter.isLoading ? nil : indexPath
    }
}

// MARK: - UITableViewDataSource

extension MyNftViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.isLoading ? shimmerViews.count : presenter.nfts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !presenter.isLoading else {
            let cell = UITableViewCell()
            let shimmerView = helper.createShimmerView()
            cell.contentView.addSubview(shimmerView)
            shimmerView.translatesAutoresizingMaskIntoConstraints = false
            shimmerView.constraintEdges(to: cell.contentView)
            return cell
        }

        let cell: MyNftCell = tableView.dequeueReusableCell()
        let nft = presenter.nfts[indexPath.row]
        let isLiked = presenter.isLiked(nft: nft)
        let priceText = String(format: "%.2f", nft.price)
        let currencyText = "ETH"

        cell.configure(with: nft,
                       isLiked: isLiked,
                       priceText: priceText,
                       currencyText: currencyText) { [weak self] likedNft in
            self?.presenter.toggleLike(for: likedNft)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - Actions

extension MyNftViewController {
    @objc
    private func sortButtonTapped() {
        showSortActionSheet()
    }

    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func handleRefresh() {
        presenter.refreshData()
    }
}

// MARK: - Sort

extension MyNftViewController {

    private func showSortActionSheet() {
        let alertController = UIAlertController(
            title: LocalizationKey.sortTitle.localized(),
            message: nil,
            preferredStyle: .actionSheet
        )

        let sortByPriceAction = UIAlertAction(
            title: LocalizationKey.sortByPrice.localized(),
            style: .default
        ) { [weak self] _ in
            self?.presenter.setSortType(.price)
        }

        let sortByRatingAction = UIAlertAction(
            title: LocalizationKey.sortByRating.localized(),
            style: .default
        ) { [weak self] _ in
            self?.presenter.setSortType(.rating)
        }

        let sortByNameAction = UIAlertAction(
            title: LocalizationKey.sortByName.localized(),
            style: .default
        ) { [weak self] _ in
            self?.presenter.setSortType(.name)
        }

        let cancelAction = UIAlertAction(
            title: LocalizationKey.actionClose.localized(),
            style: .cancel,
            handler: nil
        )

        [sortByPriceAction, sortByRatingAction, sortByNameAction, cancelAction].forEach {
            alertController.addAction($0)
        }

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - MyNftProtocol

extension MyNftViewController: MyNftProtocol {

    func cellForRow(at index: Int) -> MyNftCell? {
        let indexPath = IndexPath(row: index, section: 0)
        return tableView.cellForRow(at: indexPath) as? MyNftCell
    }

    func reloadRow(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func reloadData() {
        if presenter.isLoading {
            startLoading()
        } else {
            stopLoading()
        }

        tableView.reloadData()
        checkForData()

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    func showError(message: String) {
        helper.presentError(on: self, message: message) { [weak self] in
            self?.presenter.refreshData()
        }
    }

    func startLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presenter.isLoading = true
            self.shimmerViews = self.helper.createShimmerViews(count: 6)
            self.tableView.reloadData()
        }
    }

    func stopLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presenter.isLoading = false
            self.shimmerViews.removeAll()
            self.tableView.reloadData()
        }
    }
}
