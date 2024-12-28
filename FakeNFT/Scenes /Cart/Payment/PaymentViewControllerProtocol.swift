//
//  PaymentViewControllerProtocol.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 25.12.2024.
//

protocol PaymentViewControllerProtocol: AnyObject {
    func loadAWebView(urlString: String)
    func showUnsuccesfullPaymentAlert()
    func showSucessfulPaymentScreen()
    func showCurrenciesLoadingErrorAlert()
    func updateCurrencies()
}
