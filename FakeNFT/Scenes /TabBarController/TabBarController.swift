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

        let catalogController = CatalogViewController(
            presenter: CatalogPresenter(),
            servicesAssembly: servicesAssembly
        )

        let cartController = TestCartViewController(
            servicesAssembly: servicesAssembly
        )

        let statisticsController = TestStatisticsViewController(
            servicesAssembly: servicesAssembly
        )

        profileController.tabBarItem = profileTabBarItem
        catalogController.tabBarItem = catalogTabBarItem
        cartController.tabBarItem = cartTabBarItem
        statisticsController.tabBarItem = statisticsTabBarItem

        viewControllers = [
            profileController,
            UINavigationController(rootViewController: catalogController),
            cartController,
            statisticsController]

        setupUI()
    }

    private func setupUI() {
        tabBar.unselectedItemTintColor = UIColor(named: "ypBlack")
        tabBar.backgroundColor = UIColor(named: "ypWhite")
    }
}
