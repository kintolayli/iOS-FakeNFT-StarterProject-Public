//
//  CartPresenterProtocol.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 24.12.2024.
//

protocol CartPresenterProtocol: AnyObject {
    var items: [CartItem] { get }
    var viewController: CartViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func removeItemByNftId(nftId: String)
}
