import UIKit
import Kingfisher


protocol CatalogViewControllerProtocol: AnyObject {
    func updateView()
    func showAlert(with model: AlertModel)
}


final class CatalogViewController: UIViewController, CatalogViewControllerProtocol {
    var presenter: CatalogPresenterProtocol

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var dataSource: UITableViewDiffableDataSource<CatalogSection, NFTCollectionModel> = {
        UITableViewDiffableDataSource<CatalogSection, NFTCollectionModel>(tableView: tableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CatalogTableViewCell.reuseIdentifier
            ) as? CatalogTableViewCell else {
                return UITableViewCell()
            }

            switch CatalogSection(rawValue: indexPath.section) {
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

    init(presenter: CatalogPresenterProtocol) {
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
        presenter.loadInitialData()

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
        var snapshot = NSDiffableDataSourceSnapshot<CatalogSection, NFTCollectionModel>()

        if presenter.isLoading {
            snapshot.appendSections([.loading])
            let placeholders = (0..<Constants.placeholdersCount).map { _ in
                NFTCollectionModel(createdAt: "", name: "", cover: URL(fileURLWithPath: ""), nfts: [UUID()], description: "", author: "", id: UUID())
            }
            snapshot.appendItems(placeholders, toSection: .loading)
        } else {
            snapshot.deleteSections([.loading])
            snapshot.appendSections([.data])
            let items = presenter.collections.map { collection in
                NFTCollectionModel(
                    createdAt: collection.createdAt,
                    name: collection.name,
                    cover: collection.cover,
                    nfts: collection.nfts,
                    description: collection.description,
                    author: collection.author,
                    id: collection.id
                )
            }
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
        return presenter.isLoading ? Constants.placeholdersCount : presenter.collections.count
    }

    func configureCell(_ cell: CatalogTableViewCell, _ item: NFTCollectionModel) {
        cell.delegate = self
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        if presenter.isLoading {
            cell.startShimmering()
        } else {
            cell.stopShimmering()

            let NFTCollectionCoverImageURL = item.cover
            let imageView = UIImageView()
            let processor = RoundCornerImageProcessor(cornerRadius: Constants.cornerRadius)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: NFTCollectionCoverImageURL,
                                  placeholder: .none,
                                  options: [.processor(processor)]) { result in
                switch result {
                case .success:
                    let collectionCount = item.nfts.count
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

        let selectedCollection = presenter.collections[indexPath.row]
        let viewController = NFTCollectionViewController(
            currentCollection: selectedCollection,
            presenter: NFTCollectionPresenter())

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CatalogViewController {
    func showAlert(with model: AlertModel) {
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}
