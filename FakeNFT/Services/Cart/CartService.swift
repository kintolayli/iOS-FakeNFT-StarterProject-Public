//
//  CartService.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 15.12.2024.
//

/// Класс для управления корзиной
final class CartService {
    static let shared = CartService()
    
    private(set) var items: [CartItem] = []
    
    func addItem(_ item: CartItem) {
        if !items.contains(where: {$0.nftId == item.nftId}) {
            items.append(item)
        }
    }
    
    func removeItemByNftId(_ id: String) {
        items.removeAll(where: {$0.nftId == id})
    }
    
    func checkItemInCartByNftId(_ id: String) -> Bool {
        return items.contains(where: {$0.nftId == id})
    }
}

extension CartService {
    func mockCart() {
        items = CartMocks.mockCart + CartMocks.mockCart
    }
}
