import UIKit

protocol CatalogViewControllerProtocol: AnyObject {
    var presenter: CatalogPresenterProtocol? { get set }
    var catalog: [NFTCollectionModel] { get set }
    var tableView: UITableView { get }
    var catalogService: CatalogService { get }
    func reloadRows(indexPath: IndexPath)
}


final class CatalogViewController: UIViewController, CatalogViewControllerProtocol {
    let catalogService = CatalogService.shared
    private var catalogServiceObserver: NSObjectProtocol?
    var presenter: CatalogPresenterProtocol?

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    var catalog: [NFTCollectionModel] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        self.presenter = CatalogPresenter(viewController: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupObserver()
    }

    private func setupObserver() {
        UIBlockingProgressHUD.show()
        catalogService.fetchCatalog() { _ in }
        catalogServiceObserver = NotificationCenter.default
            .addObserver(
                forName: CatalogService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }

                self.updateTableViewAnimated()
                sortNFTCollectionsByCurrentSortMethod()
                UIBlockingProgressHUD.dismiss()
            }
    }

    private func updateTableViewAnimated() {
        let oldCount = catalog.count
        let newCount = catalogService.catalog.count
        catalog = catalogService.catalog
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    func reloadRows(indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func setupUI() {
        view.backgroundColor = Asset.ypWhite.color

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        addFilterButton()

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func addFilterButton() {
        let filterButton = UIButton(type: .custom)
        filterButton.setImage(Asset.light.image, for: .normal)
        filterButton.tintColor = Asset.ypBlack.color
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
    }

    private func sortCollectionsAlphabetically() {
        catalog = catalog.sorted { $0.name < $1.name }
        tableView.reloadData()
        saveSortMethod(.alphabetically)
    }

    private func sortCollectionsByNFTCount() {
        catalog = catalog.sorted { $0.nfts.count > $1.nfts.count }
        tableView.reloadData()
        saveSortMethod(.byNFTCount)
    }

    private func loadSortMethod() -> SortMethod {
        let defaults = UserDefaults.standard
        let sortMethodRawValue = defaults.string(forKey: "sortMethod") ?? SortMethod.alphabetically.rawValue
        return SortMethod(rawValue: sortMethodRawValue) ?? .alphabetically
    }

    private func sortNFTCollectionsByCurrentSortMethod() {
        let currentSortMethod = loadSortMethod()

        switch currentSortMethod {
        case .alphabetically:
            sortCollectionsAlphabetically()
        case .byNFTCount:
            sortCollectionsByNFTCount()
        }
    }

    private func saveSortMethod(_ method: SortMethod) {
        let defaults = UserDefaults.standard
        defaults.set(method.rawValue, forKey: "sortMethod")
    }

    @objc
    private func filterButtonDidTap() {

        let sortType1Title = L10n.CatalogController.SortNFT.sortType1
        let sortType2Title = L10n.CatalogController.SortNFT.sortType2
        let closeTitle = L10n.CatalogController.SortNFT.closeTitle
        let sortTitle = L10n.CatalogController.SortNFT.sortTitle

        let model = AlertModel(
            title: sortTitle,
            message: nil,
            actions: [
                AlertActionModel(title: sortType1Title, style: .default) { [weak self] _ in
                    self?.sortCollectionsAlphabetically()
                },
                AlertActionModel(title: sortType2Title, style: .default) { [weak self] _ in
                    self?.sortCollectionsByNFTCount()
                },
                AlertActionModel(title: closeTitle, style: .cancel, handler: nil),
            ]
        )
        AlertPresenter.show(model: model, viewController: self, preferredStyle: .actionSheet)
    }
}

extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalog.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.reuseIdentifier) as? CatalogTableViewCell else {
            return UITableViewCell()
        }

        cell.prepareForReuse()
        cell.delegate = self

        self.presenter?.configCell(for: cell, with: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = CGFloat(179)

        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCollection = catalog[indexPath.row]
        let viewController = NFTCollectionViewController(currentCollection: selectedCollection)

        navigationController?.pushViewController(viewController, animated: true)
    }
}
