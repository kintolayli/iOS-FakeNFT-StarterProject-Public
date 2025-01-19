//
//  NFTCardPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 10.01.2025.
//

import Foundation


protocol NFTCardPresenterProtocol: AnyObject {
    func getCurrentCollectionTitle() -> String
    func getCurrentNFT() -> NftModel
    func getNft(indexPath: IndexPath) -> NftModel
    func getNfts() -> [NftModel]
    func getCellData() -> (likes: [UUID], nftsInCart: [UUID])
        
    func getCryptoCurrencies() -> [CryptoCurrencyModel]
    func getCryptoCurrency(indexPath: IndexPath) -> CryptoCurrencyModel
    func getСurrentCurrencyPrice(id: Int) -> Double
    func calculatePriceInOtherCurrency(priceInEth: Double, currencyId: Int) -> Double
    
    func loadNFTsInCart(completion: @escaping (Bool) -> Void)
    func loadInitialData(completion: @escaping (Bool) -> Void)
    func getLoadingStatus() -> Bool
    
    func sendLike(nftId: UUID, completion: @escaping (Bool) -> Void)
    func sendNFTToCart(nft: NftModel, completion: @escaping (Bool) -> Void)
}

final class NFTCardPresenter: NFTCardPresenterProtocol {
    private let likeService: NFTLikeService
    private let cartService = CartService.shared
    private let cryptoCurrenciesService: NFTCryptoCurrenciesService
    private let currentCollectionTitle: String
    private let currentNFT: NftModel
    private var nfts: [NftModel]
    private var likes: [UUID] = []
    private var nftsInCart: [UUID] = []
    private var isLoading: Bool
    private let profileId = 1
    
    private var cryptoCurrencies: [CryptoCurrencyModel] = []
    
    weak var viewController: NFTCardViewControllerProtocol?
    
    init(currentNFT: NftModel, currentCollectionTitle: String, nfts: [NftModel]) {
        self.currentNFT = currentNFT
        self.currentCollectionTitle = currentCollectionTitle
        self.likeService = NFTLikeService.shared
        self.cryptoCurrenciesService = NFTCryptoCurrenciesService.shared
        self.isLoading = UIBlockingProgressHUD.status()
        self.nfts = nfts
    }
    
    func loadCryptoCurrencies(completion: @escaping (Bool) -> Void) {
        cryptoCurrenciesService.fetchCryptoCurrencies() { [ weak self ] result in
            switch result {
            case .success(let cryptoCurrencies):
                self?.cryptoCurrencies = cryptoCurrencies
                completion(true)
            case .failure(_):
                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                self?.viewController?.showAlert(with: alertModel)
            }
        }
    }
    
    func loadLikes(completion: @escaping (Bool) -> Void) {
        likeService.fetchLikes(profileId: profileId) { [ weak self ] result in
            switch result {
            case .success(let likedNFT):
                self?.likes = likedNFT
                completion(true)
                
            case .failure(_):
                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                self?.viewController?.showAlert(with: alertModel)
            }
        }
    }
    
    func sendLike(nftId: UUID, completion: @escaping (Bool) -> Void) {
        likeService.sendLike(profileId: profileId, nftId: nftId) { [ weak self ] result in
            switch result {
            case .success(_):
                self?.loadLikes { _ in
                    completion(true)
                }
                
            case .failure(_):
                let alertModel = AlertModel(
                    title: L10n.Error.title,
                    message: L10n.Error.loadingLikeError,
                    actions: [
                        AlertActionModel(title: L10n.Alert.ok, style: .cancel, handler: nil)
                    ]
                )
                self?.viewController?.showAlert(with: alertModel)
                completion(true)
            }
        }
    }
    
    func loadNFTsInCart(completion: @escaping (Bool) -> Void) {
        nftsInCart = cartService.getOnlyItemsId().compactMap{UUID(uuidString: $0)}
        completion(true)
    }
    
    func sendNFTToCart(nft: NftModel, completion: @escaping (Bool) -> Void) {
        let itemImageUrl = nft.images[0].absoluteString
        let itemId = nft.id.uuidString.lowercased()
        let cartItem = CartItem(nftId: itemId, name: nft.name, rating: nft.rating, price: Float(nft.price), imageUrl: itemImageUrl)

        if cartService.checkItemInCartByNftId(itemId) {
            cartService.removeItemByNftId(itemId)
        } else {
            cartService.addItem(cartItem)
        }

        loadNFTsInCart { _ in
            completion(true)
        }
    }
    
    func loadInitialData(completion: @escaping (Bool) -> Void) {
        let cellModels = currentNFT.images.map { NftDetailCellModel(url: $0) }
        viewController?.displayCells(cellModels)
        
        loadCryptoCurrencies { _ in
            self.loadNFTsInCart { _ in
                self.loadLikes { _ in
                    completion(true)
                }
            }
        }
    }
    
    func getCellData() -> (likes: [UUID], nftsInCart: [UUID]) {
        return (likes: likes, nftsInCart: nftsInCart)
    }
    
    func getCurrentCollectionTitle() -> String {
        return currentCollectionTitle
    }
    
    func getCurrentNFT() -> NftModel {
        return currentNFT
    }
    
    func getNft(indexPath: IndexPath) -> NftModel {
        return nfts[indexPath.row]
    }
    
    func getNfts() -> [NftModel] {
        return nfts
    }
    
    func getCryptoCurrencies() -> [CryptoCurrencyModel] {
        return cryptoCurrencies
    }
    
    func getCryptoCurrency(indexPath: IndexPath) -> CryptoCurrencyModel {
        return cryptoCurrencies[indexPath.row]
    }
    
    func getShibaInuPrice() -> Double {
        return 0.000022
    }
    
    func getCardanoPrice() -> Double {
        return 0.997997
    }
    
    func getTetherPrice() -> Double {
        return 0.999658
    }
    
    func getApecoinPrice() -> Double {
        return 1.07
    }
    
    func getSolanaPrice() -> Double {
        return 187.42
    }
    
    func getBitcoinPrice() -> Double {
        return 96899
    }
    
    func getDogecoinPrice() -> Double {
        return 0.358763
    }
    
    func getEthereumPrice() -> Double {
        return 3222.86
    }
    
    func getСurrentCurrencyPrice(id: Int) -> Double {
        switch id {
        case 0:
            let price = getShibaInuPrice()
            return price
        case 1:
            let price = getCardanoPrice()
            return price
        case 2:
            let price = getTetherPrice()
            return price
        case 3:
            let price = getApecoinPrice()
            return price
        case 4:
            let price = getSolanaPrice()
            return price
        case 5:
            let price = getBitcoinPrice()
            return price
        case 6:
            let price = getDogecoinPrice()
            return price
        case 7:
            let price = getEthereumPrice()
            return price
        default:
            return 0.000
        }
    }
    
    func calculatePriceInOtherCurrency(priceInEth: Double, currencyId: Int) -> Double {
        let ethPrice = getEthereumPrice()
        let priceInDollars = ethPrice * priceInEth
        let otherCurrencyPrice = getСurrentCurrencyPrice(id: currencyId)
        return priceInDollars / otherCurrencyPrice
    }
    
    func getLoadingStatus() -> Bool {
        return isLoading
    }
}
