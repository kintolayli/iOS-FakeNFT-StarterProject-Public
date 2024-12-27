//
//  PaymentPresenter.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 25.12.2024.
//

final class PaymentPresenter: PaymentPresenterProtocol {
    weak var viewController: PaymentViewControllerProtocol?
    
    private let cartService: CartService
    private let paymentNetworkService: PaymentNetworkService

    init(cartService: CartService, paymentNetworkService: PaymentNetworkService) {
        self.cartService = cartService
        self.paymentNetworkService = paymentNetworkService
    }
    
    var currencies: [Currency] {
        CurrencyMocks.currencies
    }
    
    private let agreementUrl = "https://yandex.ru/legal/practicum_termsofuse/"

    func viewDidLoad() {

    }
    
    func openAgreementView() {
        viewController?.loadAWebView(urlString: agreementUrl)
    }
    
    func payOrder() {
        paymentNetworkService.getOrder { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let order):
                self.putOrder(orderId: order.id)
            case .failure(let error):
                print("\(#file):\(#function): \(error)")
                self.viewController?.showUnsuccesfullPaymentAlert()
            }
        }
    }
    
    private func putOrder(orderId: String) {
        paymentNetworkService.putOrder(nfts: cartService.items.map({$0.nftId}), orderId: orderId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                break
            case .failure(let error):
                print("\(#file):\(#function): \(error)")
                self.viewController?.showUnsuccesfullPaymentAlert()
            }
        }
    }
    
    private func payOrderWithCurrencyId(currencyId: String) {
        paymentNetworkService.payOrderWithCurrencyId(currencyId: currencyId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let status):
                switch status.success {
                case true:
                    self.viewController?.showSucessfulPaymentScreen()
                case false:
                    print("\(#file):\(#function): The payment processed by server with success state: \(status.success)")
                    self.viewController?.showUnsuccesfullPaymentAlert()
                }
            case .failure(let error):
                print("\(#file):\(#function): \(error)")
                self.viewController?.showUnsuccesfullPaymentAlert()
            }
        }
    }
}
