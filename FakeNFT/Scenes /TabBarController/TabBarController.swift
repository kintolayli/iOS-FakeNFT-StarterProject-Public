import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let profileTabBarItem = UITabBarItem(
        title: L10n.Tab.profile,
        image: Asset.profileTabBarItemImage.image,
        tag: 0
    )

    private let catalogTabBarItem = UITabBarItem(
        title: L10n.Tab.catalog,
        image: Asset.catalogTabBarItemImage.image,
        tag: 1
    )

    private let cartTabBarItem = UITabBarItem(
        title: L10n.Tab.cart,
        image: Asset.cartTabBarItemImage.image,
        tag: 2
    )

    private let statisticsTabBarItem = UITabBarItem(
        title: L10n.Tab.statistics,
        image: Asset.statisticsTabBarItemImage.image,
        tag: 3
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileNavigationController = createProfileViewController()

        let catalogController = CatalogViewController(
            presenter: CatalogPresenter(),
            servicesAssembly: servicesAssembly
        )
        catalogController.view.backgroundColor = .systemBackground
        catalogController.tabBarItem = catalogTabBarItem
        
        let cartPresenter = CartPresenter(cartService: CartService.shared)
        let cartController = CartViewController(presenter: cartPresenter)
        let cartNavigationColntroller = UINavigationController(rootViewController: cartController)
        cartController.tabBarItem = cartTabBarItem

        let statisticsController = TestStatisticsViewController(
            servicesAssembly: servicesAssembly
        )
        statisticsController.view.backgroundColor = .systemBackground
        statisticsController.tabBarItem = statisticsTabBarItem

        viewControllers = [
            profileNavigationController,
            UINavigationController(rootViewController: catalogController),
            cartNavigationColntroller,
            statisticsController]

        view.backgroundColor = .systemBackground
        tabBar.unselectedItemTintColor = .ypBlack
    }

    private func createProfileViewController() -> UINavigationController {
        
        let profileService = servicesAssembly.profileService
        let nftService = servicesAssembly.myNftService
        let likeService = servicesAssembly.likeService
        

        let profileRepository = ProfileRepositoryImpl(profileService: profileService)
        
        
        
        let profileRouter = ProfileRouter(
            profileService: profileService,
            nftService: nftService,
            likeService: likeService
        )

        let profilePresenter = ProfilePresenter(
            router: profileRouter,
            repository: profileRepository
        )
        let profileController = ProfileViewController(presenter: profilePresenter)
        profilePresenter.view = profileController
        profileRouter.viewController = profileController
        profileController.tabBarItem = profileTabBarItem
        return UINavigationController(rootViewController: profileController)
    }
}
