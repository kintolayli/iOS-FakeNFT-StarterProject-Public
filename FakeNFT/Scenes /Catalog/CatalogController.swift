import UIKit
import Kingfisher

protocol CatalogViewControllerProtocol: AnyObject {
    func updateView()
    func updateRowsAnimated(newCollections: [NFTCollectionModel], oldCollections: [NFTCollectionModel])
    func applySortMethod()
    func showAlert(with model: AlertModel)
    func sortCollectionsAlphabetically()
    func sortCollectionsByNFTCount()
}


final class CatalogViewController: UIViewController, CatalogViewControllerProtocol {
    var presenter: CatalogPresenterProtocol
    private var sortMethod: SortMethod

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    init(presenter: CatalogPresenterProtocol) {
        self.presenter = presenter
        self.sortMethod = CatalogViewController.loadSortMethod()
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sortMethod = CatalogViewController.loadSortMethod()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter.viewController = self
        presenter.loadInitialData()
    }

    private func setupUI() {
        view.backgroundColor = Asset.ypWhite.color

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        addFilterButton()
    }

    private func addFilterButton() {
        let filterButton = UIButton(type: .custom)
        filterButton.setImage(Asset.light.image, for: .normal)
        filterButton.tintColor = Asset.ypBlack.color
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
    }

    @objc
    private func filterButtonDidTap() {
        presenter.filterButtonTapped()
    }

    func updateView() {
        tableView.reloadData()
    }

    func updateRowsAnimated(newCollections: [NFTCollectionModel], oldCollections: [NFTCollectionModel]) {
        let newCount = newCollections.count
        let oldCount = oldCollections.count

        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}


extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.collections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.reuseIdentifier) as? CatalogTableViewCell else {
            return UITableViewCell()
        }

        cell.prepareForReuse()
        cell.delegate = self

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let NFTCollectionCoverImageURL = presenter.collections[indexPath.item].cover
        let imageView = UIImageView()
        let processor = RoundCornerImageProcessor(cornerRadius: 12)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: NFTCollectionCoverImageURL,
                              placeholder: .none,
                              options: [.processor(processor)]) { result in
            switch result {
            case .success:
                let collectionCount = self.presenter.collections[indexPath.item].nfts.count
                let collectionName = self.presenter.collections[indexPath.item].name
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

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 179
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCollection = presenter.collections[indexPath.row]
        let viewController = NFTCollectionViewController(currentCollection: selectedCollection)

        navigationController?.pushViewController(viewController, animated: true)
    }
}


extension CatalogViewController {

    private static func loadSortMethod() -> SortMethod {
        let sortMethodRawValue = UserDefaults.standard.string(forKey: "CatalogSortMethod") ?? SortMethod.alphabetically.rawValue
        return SortMethod(rawValue: sortMethodRawValue) ?? .alphabetically
    }

    private func saveSortMethod() {
        UserDefaults.standard.set(sortMethod.rawValue, forKey: "CatalogSortMethod")
    }

    func sortCollectionsAlphabetically() {
        presenter.sortCollectionsAlphabetically()
        sortMethod = .alphabetically
        saveSortMethod()
        updateView()
    }

    func sortCollectionsByNFTCount() {
        presenter.sortCollectionsByNFTCount()
        sortMethod = .byNFTCount
        saveSortMethod()
        updateView()
    }

    func applySortMethod() {
        switch sortMethod {
        case .alphabetically:
            sortCollectionsAlphabetically()
        case .byNFTCount:
            sortCollectionsByNFTCount()
        }
    }
}

extension CatalogViewController {
    func showAlert(with model: AlertModel) {
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}
