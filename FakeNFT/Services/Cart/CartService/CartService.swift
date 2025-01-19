//
//  CartService.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 15.12.2024.
//

import Foundation

enum CartSortingType: Int {
    case byTitle = 0
    case byRating = 1
    case byPrice = 2
}

/// Класс для управления корзиной
final class CartService {
    static let shared = CartService()
    
    private(set) var items: [CartItem] = []
    
    func addItem(_ item: CartItem) {
        if !items.contains(where: {$0.nftId == item.nftId}) {
            items.append(item)
        }
    }

    func getOnlyItemsId() -> [String] {
        return items.map{$0.nftId}
    }

    func removeItemByNftId(_ id: String) {
        items.removeAll(where: {$0.nftId == id})
    }
    
    func checkItemInCartByNftId(_ id: String) -> Bool {
        return items.contains(where: {$0.nftId == id})
    }
    
    func clearCart() {
        items.removeAll()
    }
    
    func sortItems(sortingType: CartSortingType) {
        switch sortingType {
        case .byPrice:
            items.sort { item1, item2 in
                item1.price < item2.price
            }
        case .byRating:
            items.sort { item1, item2 in
                item1.rating < item2.rating
            }
        case .byTitle:
            items.sort { item1, item2 in
                item1.name < item2.name
            }
        }
    }
}

extension CartService {
    func mockCart() {
        items = CartMocks.mockCart
    }
}
