import UIKit

final class CartViewController: UIViewController, CartViewControllerProtocol {
    private var presenter: CartPresenterProtocol
    private let cartTableView = UITableView(frame: .zero, style: .plain)
    
    private let orderDatailsView = UIView()
    private let totalCostLabel = UILabel()
    private let itemCounterLabel = UILabel()
    private let proceedPaymentButton = UIButton()
    private let plugLabel = UILabel()
    
    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.viewController = self
        view.backgroundColor = UIColor(resource: .ypWhite)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        
        setupNavigationItem()
        setupOrderDetailsView()
        setupCartTableView()
        setupPlugLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.sortCartItems(sortingType: nil)
        presenter.updateOrderDetails()
        updatePlugLabelVisibility()
        cartTableView.reloadData()
    }
    
    func updateOrderDetails(totalCost: Float, itemsCount: Int) {
        totalCostLabel.text = String(format: "%.2f ETH", totalCost)
        itemCounterLabel.text = "\(itemsCount) NFT"
    }
    
    private func setupNavigationItem() {
        let sortButton = UIButton(type: .custom)
        sortButton.setImage(UIImage(resource: .sort), for: .normal)
        sortButton.tintColor = UIColor(resource: .ypBlack)
        sortButton.addTarget(self, action: #selector(didTapSortButton), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    }
    
    @objc
    private func didTapSortButton() {
        showCartSortingAlert()
    }
    
    private func updatePlugLabelVisibility() {
        cartTableView.isHidden = presenter.items.isEmpty
        plugLabel.isHidden = !presenter.items.isEmpty
    }
    
    private func setupPlugLabel() {
        plugLabel.text = L10n.Cart.plug
        plugLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        plugLabel.textColor = UIColor(resource: .ypBlack)
        plugLabel.textAlignment = .center
        
        plugLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(plugLabel)
        
        NSLayoutConstraint.activate([
            plugLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            plugLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            plugLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCartTableView() {
        cartTableView.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.identifier)
        cartTableView.dataSource = self
        cartTableView.backgroundColor = UIColor(resource: .ypWhite)
        cartTableView.allowsSelection = false
        cartTableView.separatorStyle = .none
        cartTableView.rowHeight = 140
        cartTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

        cartTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cartTableView)
        
        NSLayoutConstraint.activate([
            cartTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cartTableView.bottomAnchor.constraint(equalTo: orderDatailsView.topAnchor),
            cartTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cartTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupOrderDetailsView() {
        orderDatailsView.backgroundColor = UIColor(resource: .ypLightGrey)
                
        totalCostLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        totalCostLabel.textColor = UIColor(resource: .ypGreen)
        
        itemCounterLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        itemCounterLabel.textColor = UIColor(resource: .ypBlack)
        
        proceedPaymentButton.setTitle(L10n.Cart.payment, for: .normal)
        proceedPaymentButton.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        proceedPaymentButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        proceedPaymentButton.backgroundColor = UIColor(resource: .ypBlack)
        proceedPaymentButton.layer.cornerRadius = 16
        proceedPaymentButton.clipsToBounds = true
        proceedPaymentButton.addTarget(self, action: #selector(didTapProceedPaymentButton), for: .touchUpInside)

        orderDatailsView.translatesAutoresizingMaskIntoConstraints = false
        totalCostLabel.translatesAutoresizingMaskIntoConstraints = false
        itemCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        proceedPaymentButton.translatesAutoresizingMaskIntoConstraints = false
        
        orderDatailsView.addSubview(totalCostLabel)
        orderDatailsView.addSubview(itemCounterLabel)
        orderDatailsView.addSubview(proceedPaymentButton)
        view.addSubview(orderDatailsView)
        
        NSLayoutConstraint.activate([
            orderDatailsView.heightAnchor.constraint(equalToConstant: 76),
            orderDatailsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            orderDatailsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            orderDatailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            itemCounterLabel.topAnchor.constraint(equalTo: orderDatailsView.topAnchor, constant: 16),
            itemCounterLabel.leadingAnchor.constraint(equalTo: orderDatailsView.leadingAnchor, constant: 16),
        ])
        
        NSLayoutConstraint.activate([
            totalCostLabel.leadingAnchor.constraint(equalTo: orderDatailsView.leadingAnchor, constant: 16),
            totalCostLabel.bottomAnchor.constraint(equalTo: orderDatailsView.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            proceedPaymentButton.widthAnchor.constraint(equalToConstant: 240),
            proceedPaymentButton.topAnchor.constraint(equalTo: orderDatailsView.topAnchor, constant: 16),
            proceedPaymentButton.bottomAnchor.constraint(equalTo: orderDatailsView.bottomAnchor, constant: -16),
            proceedPaymentButton.trailingAnchor.constraint(equalTo: orderDatailsView.trailingAnchor, constant: -16),
        ])
    }
    
    @objc
    private func didTapProceedPaymentButton() {
        let paymentPresenter = PaymentPresenter(
            cartService: CartService.shared,
            paymentNetworkService: PaymentNetworkService(networkClient: DefaultNetworkClient())
        )
        let paymentViewController = PaymentViewController(presenter: paymentPresenter)
        paymentViewController.delegate = self
        let paymentNavigationColntroller = UINavigationController(rootViewController: paymentViewController)
        paymentNavigationColntroller.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        paymentNavigationColntroller.modalPresentationStyle = .fullScreen
        present(paymentNavigationColntroller, animated: true)
    }
    
    private func showCartSortingAlert() {
        let alert = UIAlertController(title: "", message: "Сортировка", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "По цене", style: .default) { [weak self] action in
            self?.presenter.sortCartItems(sortingType: .byPrice)
            self?.cartTableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "По рейтингу", style: .default) { [weak self] action in
            self?.presenter.sortCartItems(sortingType: .byRating)
            self?.cartTableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "По названию", style: .default) { [weak self] action in
            self?.presenter.sortCartItems(sortingType: .byTitle)
            self?.cartTableView.reloadData()
        })
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell
        else {
            return CartTableViewCell()
        }
        cell.item = presenter.items[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension CartViewController: CartTableViewCellDelegate {
    func removeItem(_ item: CartItem) {
        let removingViewController = CartRemovingViewController()
        removingViewController.item = item
        removingViewController.delegate = self
        removingViewController.modalPresentationStyle = .overFullScreen
        present(removingViewController, animated: true)
    }
}

extension CartViewController: CartRemovingViewControllerDelegate {
    func removeItem(nftId: String) {
        presenter.removeItemByNftId(nftId: nftId)
        cartTableView.reloadData()
        updatePlugLabelVisibility()
    }
}

extension CartViewController: PaymentViewControllerDelegate {
    func returnToCatalogTab() {
        tabBarController?.selectedIndex = 1
    }
}
