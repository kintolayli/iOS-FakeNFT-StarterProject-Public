import UIKit
import Kingfisher


protocol CatalogViewControllerProtocol: AnyObject {
    func updateView()
    func showAlert(with model: AlertModel)
}


final class CatalogViewController: UIViewController, CatalogViewControllerProtocol {
    var presenter: CatalogPresenterProtocol
    private let servicesAssembly: ServicesAssembly

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<LoadingSectionModel, NFTCollectionModel> = {
        UITableViewDiffableDataSource<LoadingSectionModel, NFTCollectionModel>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CatalogTableViewCell.reuseIdentifier
            ) as? CatalogTableViewCell else {
                return UITableViewCell()
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

    let filterButton = UIButton(type: .custom)

    init(presenter: CatalogPresenterProtocol, servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
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

        UIBlockingProgressHUD.show()
        presenter.loadInitialData { _ in
            UIBlockingProgressHUD.dismiss()
        }
        applySnapshot()
    }

    private func setupUI() {
        view.backgroundColor = Asset.ypWhite.color

        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        addFilterButton()
    }

    private func addFilterButton() {
        filterButton.setImage(Asset.light.image, for: .normal)
        filterButton.tintColor = Asset.ypBlack.color
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
    }

    @objc
    private func filterButtonDidTap() {
        presenter.filterButtonTapped()
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<LoadingSectionModel, NFTCollectionModel>()
        let isLoading = presenter.getLoadingStatus()

        if isLoading {
            snapshot.appendSections([.loading])

            let placeholders = presenter.createPlaceholderCollections()
            snapshot.appendItems(placeholders, toSection: .loading)
        } else {
            snapshot.deleteSections([.loading])
            snapshot.appendSections([.data])

            let items = presenter.createCollections()
            snapshot.appendItems(items, toSection: .data)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    func updateView() {
        applySnapshot()
    }
}


extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let collections = presenter.getCollections()
        let isLoading = presenter.getLoadingStatus()
        return isLoading ? Constants.placeholdersCount : collections.count
    }

    func configureCell(_ cell: CatalogTableViewCell, _ item: NFTCollectionModel) {
        cell.delegate = self
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let isLoading = presenter.getLoadingStatus()

        if isLoading {
            cell.startShimmering()
        } else {
            cell.stopShimmering()

            let NFTCollectionCoverImageURL = item.cover
            let imageView = UIImageView()
            let processor = RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius12)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: NFTCollectionCoverImageURL,
                                  placeholder: .none,
                                  options: [.processor(processor)]) { result in
                switch result {
                case .success:
                    // TODO: - Сервер поломан - в некоторых коллекциях присылается несколько одинаковых NFT с одинаковыми Id, и diffable data source ломается. Строчка ниже это костыль чтобы временно эту проблему решить.
                    let nftsUnique = Array(Set(item.nfts))
                    let collectionCount = nftsUnique.count
                    let collectionName = item.name
                    let collectionTitle = "\(collectionName) (\(collectionCount))"

                    guard let collectionImage = imageView.image else { return }

                    cell.updateCell(titleLabel: collectionTitle, titleImage: collectionImage)

                case .failure(let error):
                    let logMessage =
                """
                [\(String(describing: self)).\(#function)]:
                \(CatalogPresenterError.fetchImageError) - Ошибка получения изображения ячейки таблицы, \(error.localizedDescription)
                """
                    print(logMessage)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCollection = presenter.getCollection(indexPath: indexPath)
        let viewController = NFTCollectionViewController(
            presenter: NFTCollectionPresenter(currentCollection: selectedCollection),
            collection: selectedCollection,
            servicesAssembly: servicesAssembly
        )

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CatalogViewController {
    func showAlert(with model: AlertModel) {
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}
