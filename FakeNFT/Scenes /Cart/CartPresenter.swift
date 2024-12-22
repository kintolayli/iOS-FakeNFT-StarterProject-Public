//
//  CartPresenter.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 22.12.2024.
//

final class CartPresenter {
    weak var viewController: CartViewController?
    
    var items: [CartItem] {
        cartService.items
    }
        
    private let cartService: CartService
    
    init(cartService: CartService) {
        self.cartService = cartService
    }
    
    func viewDidLoad() {
        cartService.mockCart()
        viewController?.updateOrderDetails(totalCost: orderTotalCost(), itemsCount: items.count)
    }
    
    func removeItemByNftId(nftId: String) {
        cartService.removeItemByNftId(nftId)
        viewController?.updateOrderDetails(totalCost: orderTotalCost(), itemsCount: items.count)
    }
    
    private func orderTotalCost() -> Float {
        return cartService.items.map({$0.price}).reduce(.zero, +)
    }
}
