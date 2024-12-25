import UIKit

protocol CatalogViewControllerProtocol: AnyObject {
    var presenter: CatalogPresenterProtocol { get set }
    var catalogService: CatalogService { get }

    func updateView()
    func updateRowsAnimated()
}


final class CatalogViewController: UIViewController, CatalogViewControllerProtocol {
    let catalogService = CatalogService.shared
    var presenter: CatalogPresenterProtocol
    private var catalogServiceObserver: NSObjectProtocol?

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    init() {
        let presenter = CatalogPresenter(catalogService: CatalogService.shared)
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.viewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupObserver()
        presenter.loadInitialData()
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

                updateRowsAnimated()
                presenter.applySortMethod()
                UIBlockingProgressHUD.dismiss()
            }
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

    func updateRowsAnimated() {
        let oldCount = presenter.collections.count
        let newCount = catalogService.catalog.count
        presenter.collections = catalogService.catalog

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

        self.presenter.configCell(for: cell, with: indexPath)
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
