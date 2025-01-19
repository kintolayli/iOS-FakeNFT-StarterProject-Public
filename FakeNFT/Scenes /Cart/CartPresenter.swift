//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 22.12.2024.
//
import Foundation

final class CartPresenter: CartPresenterProtocol {
    weak var viewController: CartViewControllerProtocol?
    
    private let userDefaults = UserDefaults.standard
    
    private var cartSortingType: CartSortingType {
        CartSortingType(rawValue: userDefaults.integer(forKey: "cartSortingType")) ?? .byTitle
    }
    
    var items: [CartItem] {
        return cartService.items
    }

    private let cartService: CartService
    
    init(cartService: CartService) {
        self.cartService = cartService
    }
    
    func viewDidLoad() {
    }
    
    func updateOrderDetails() {
        viewController?.updateOrderDetails(totalCost: orderTotalCost(), itemsCount: items.count)
    }
    
    func sortCartItems(sortingType: CartSortingType?) {
        let sortingType = sortingType ?? cartSortingType
        userDefaults.set(sortingType.rawValue, forKey: "cartSortingType")
        cartService.sortItems(sortingType: sortingType)
    }
    
    func removeItemByNftId(nftId: String) {
        cartService.removeItemByNftId(nftId)
        viewController?.updateOrderDetails(totalCost: orderTotalCost(), itemsCount: items.count)
    }
    
    private func orderTotalCost() -> Float {
        return cartService.items.map({$0.price}).reduce(.zero, +)
    }
    
    
}
