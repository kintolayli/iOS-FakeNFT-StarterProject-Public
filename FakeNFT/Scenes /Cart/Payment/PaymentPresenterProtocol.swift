//
//  PaymentPresenterProtocol.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 25.12.2024.
//

protocol PaymentPresenterProtocol: AnyObject {
    var currencies: [Currency] { get }
    var viewController: PaymentViewControllerProtocol? { get set }
    func viewDidLoad()
    func openAgreementView()
    func payOrder()
}
