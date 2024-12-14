import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(named: "ProfileTabBarItemImage"),
        tag: 0
    )

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(named: "CatalogTabBarItemImage"),
        tag: 0
    )

    private let cartTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.cart", comment: ""),
        image: UIImage(named: "CartTabBarItemImage"),
        tag: 0
    )

    private let statisticsTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.statistics", comment: ""),
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

        viewControllers = [profileController, catalogController, cartController, statisticsController]

        setupUI()
    }

    private func setupUI() {
        tabBar.unselectedItemTintColor = UIColor(named: "ypBlack")
        tabBar.backgroundColor = UIColor(named: "ypWhite")
    }
}
