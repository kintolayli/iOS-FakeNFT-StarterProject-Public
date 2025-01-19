//
//  CartViewControllerProtocol.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 24.12.2024.
//

protocol CartViewControllerProtocol: AnyObject {
    func updateOrderDetails(totalCost: Float, itemsCount: Int)
}
