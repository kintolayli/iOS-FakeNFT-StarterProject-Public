import UIKit

protocol CatalogViewControllerProtocol: CatalogViewController {

}

final class CatalogViewController: UIViewController {

    let servicesAssembly: ServicesAssembly
//    private let testNftButton = UIButton()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CatalogTableViewCell.self, forCellReuseIdentifier: CatalogTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    private let catalogs = [
        (Asset.peachFrame9430, 11),
        (Asset.blueFrame9430, 6),
        (Asset.brownFrame9430, 8),
        (Asset.lightFrame9430, 10)
    ]

    private lazy var sortedCatalogs = {

        let sortedCatalogs = self.catalogs
        return sortedCatalogs
    }()

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sortNFTCollectionsByCurrentSortMethod()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = Asset.ypWhite.color

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        addFilterButton()
//        view.addSubview(testNftButton)


//        testNftButton.constraintCenters(to: view)
//        testNftButton.setTitle(Constants.openNftTitle, for: .normal)
//        testNftButton.addTarget(self, action: #selector(showNft), for: .touchUpInside)
//        testNftButton.setTitleColor(.systemBlue, for: .normal)

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

    @objc
    func showNft() {
        let assembly = NftDetailAssembly(servicesAssembler: servicesAssembly)
        let nftInput = NftDetailInput(id: Constants.testNftId)
        let nftViewController = assembly.build(with: nftInput)
        present(nftViewController, animated: true)
    }

    private func sortCollectionsAlphabetically() {
        sortedCatalogs = catalogs.sorted { $0.0.name < $1.0.name }
        tableView.reloadData()
        saveSortMethod(.alphabetically)
    }

    private func sortCollectionsByNFTCount() {
        sortedCatalogs = catalogs.sorted { $0.1 > $1.1 }
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
        return sortedCatalogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogTableViewCell.reuseIdentifier) as? CatalogTableViewCell else {
            return UITableViewCell()
        }

        let collectionTitle = "\(sortedCatalogs[indexPath.row].0.name) (\(sortedCatalogs[indexPath.row].1))"
        let collectionImage = sortedCatalogs[indexPath.row].0.image

        cell.updateCell(titleLabel: collectionTitle, titleImage: collectionImage)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight = CGFloat(179)

        return cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCollection = "\(sortedCatalogs[indexPath.row].0.name) (\(sortedCatalogs[indexPath.row].1))"
        let viewController = NFTCollectionViewController(currentCollection: selectedCollection)

        navigationController?.pushViewController(viewController, animated: true)
    }
}


private enum Constants {
    static let openNftTitle = L10n.Catalog.openNft
    static let testNftId = "7773e33c-ec15-4230-a102-92426a3a6d5a"
}
