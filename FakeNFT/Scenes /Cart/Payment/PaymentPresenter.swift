//
//  PaymentPresenter.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 25.12.2024.
//

final class PaymentPresenter: PaymentPresenterProtocol {
    weak var viewController: PaymentViewControllerProtocol?

    var currencies: [Currency] {
        CurrencyMocks.currencies
    }
    
    private let agreementUrl = "https://yandex.ru/legal/practicum_termsofuse/"

    func viewDidLoad() {

    }
    
    func openAgreementView() {
        viewController?.loadAWebView(urlString: agreementUrl)
    }
    
    
}
