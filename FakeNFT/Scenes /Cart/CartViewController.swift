import UIKit

class CartViewController: UIViewController {

    private let servicesAssembly: ServicesAssembly
    private let cartService = CartService.shared
    
    private let cartTableView = UITableView(frame: .zero, style: .plain)
        
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(resource: .ypWhite)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartService.mockCart()
        setupNavigationItem()
        setupCartTableView()
    }
    
    func setupNavigationItem() {
        let sortButton = UIButton(type: .custom)
        sortButton.setImage(UIImage(resource: .sort), for: .normal)
        sortButton.tintColor = UIColor(resource: .ypBlack)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
        
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
            cartTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cartTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cartTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartService.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartTableViewCell.identifier, for: indexPath) as? CartTableViewCell
        else {
            return CartTableViewCell()
        }
        
        cell.item = cartService.items[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension CartViewController: CartTableViewCellDelegate {
    func removeItem(_ nftId: String) {
        cartService.removeItemByNftId(nftId)
        cartTableView.reloadData()
    }
}
