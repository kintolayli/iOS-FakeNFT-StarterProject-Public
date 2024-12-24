import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let profileTabBarItem = UITabBarItem(
        title: L10n.Tab.profile,
        image: UIImage(named: "ProfileTabBarItemImage"),
        tag: 0
    )

    private let catalogTabBarItem = UITabBarItem(
        title: L10n.Tab.catalog,
        image: UIImage(named: "CatalogTabBarItemImage"),
        tag: 0
    )

    private let cartTabBarItem = UITabBarItem(
        title: L10n.Tab.cart,
        image: UIImage(named: "CartTabBarItemImage"),
        tag: 0
    )

    private let statisticsTabBarItem = UITabBarItem(
        title: L10n.Tab.statistics,
        image: UIImage(named: "StatisticsTabBarItemImage"),
        tag: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileController = TestProfileViewController(
            servicesAssembly: servicesAssembly
        )

        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )

        let cartPresenter = CartPresenter(cartService: CartService.shared)
        let cartController = CartViewController(presenter: cartPresenter)

        let statisticsController = TestStatisticsViewController(
            servicesAssembly: servicesAssembly
        )
        
        let cartNavigationColntroller = UINavigationController(rootViewController: cartController)
        cartNavigationColntroller.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .bold)]

        profileController.tabBarItem = profileTabBarItem
        catalogController.tabBarItem = catalogTabBarItem
        cartController.tabBarItem = cartTabBarItem
        statisticsController.tabBarItem = statisticsTabBarItem

        viewControllers = [profileController, catalogController, cartNavigationColntroller, statisticsController]

        setupUI()
    }

    private func setupUI() {
        tabBar.unselectedItemTintColor = UIColor(named: "ypBlack")
        tabBar.backgroundColor = UIColor(named: "ypWhite")
    }
}
