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
    
    private(set) var currencies: [Currency] = []

    private var selectedCurrency: Currency?

    init(cartService: CartService, paymentNetworkService: PaymentNetworkService) {
        self.cartService = cartService
        self.paymentNetworkService = paymentNetworkService
    }
    
    private let agreementUrl = "https://yandex.ru/legal/practicum_termsofuse/"

    func viewDidLoad() {
        getCurrencies()
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
    
    func selectCurrencyByIndex(index: Int) {
        selectedCurrency = currencies[index]
    }
    
    private func putOrder(orderId: String) {
        paymentNetworkService.putOrder(nfts: cartService.items.map({$0.nftId}), orderId: orderId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                guard let selectedCurrency else {
                    print("\(#file):\(#function): Currency is not set")
                    self.viewController?.showUnsuccesfullPaymentAlert()
                    return
                }
                payOrderWithCurrencyId(currencyId: selectedCurrency.id)
            case .failure(let error):
                print("\(#file):\(#function): \(error)")
                self.viewController?.showUnsuccesfullPaymentAlert()
            }
        }
    }
    
    func getCurrencies() {
        paymentNetworkService.getCurrencies() { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let currencies):
                self.currencies = currencies.map({ currencyDtoItem in
                    Currency(title: currencyDtoItem.title,
                             name: currencyDtoItem.name,
                             image: currencyDtoItem.image,
                             id: currencyDtoItem.id
                    )
                })
                self.viewController?.updateCurrancies()
            case .failure(let error):
                print("\(#file):\(#function): \(error)")
                self.viewController?.showCurrenciesLoadigErrorAlert()
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
