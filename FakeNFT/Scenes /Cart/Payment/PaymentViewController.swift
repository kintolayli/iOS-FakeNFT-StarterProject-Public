//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 18.12.2024.
//

import UIKit

protocol PaymentViewControllerDelegate: AnyObject {
    func returnToCatalogTab()
}

struct ExtendedGeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    let cellSpacing: CGFloat
    let lineSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, topInset: CGFloat, bottomInset: CGFloat , cellSpacing: CGFloat, lineSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.cellSpacing = cellSpacing
        self.lineSpacing = lineSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

final class PaymentViewController: UIViewController, PaymentViewControllerProtocol {
    weak var delegate: PaymentViewControllerDelegate?

    private var presenter: PaymentPresenterProtocol
    
    private let currenciesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let footerView = UIView()
    private let agreementButton = UIButton()
    private let payButton = UIButton()
    
    private var pickedCurrencyIndex = -1
    
    private let sectionParams = ExtendedGeometricParams(cellCount: 2,
                                                leftInset: 16,
                                                rightInset: 16,
                                                topInset: 0,
                                                bottomInset: 0,
                                                cellSpacing: 7,
                                                lineSpacing: 7
    )
    
    init(presenter: PaymentPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = Asset.ypWhite.color
        presenter.viewController = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        updatePayButtonState()
        UIBlockingProgressHUD.show()
        setupNavigationItem()
        setupFooterView()
        setupCurrenciesCollectionView()
    }
    
    func loadAWebView(urlString: String) {
        let agreementWebViewController = PaymentWebViewController()
        agreementWebViewController.load(urlString: urlString)
        navigationController?.pushViewController(agreementWebViewController, animated: true)
    }
    
    func showCurrenciesLoadingErrorAlert() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(title: L10n.Payment.currenciesAlertTitle, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n.Payment.alertCancel, style: .cancel) { [weak self] action in
            self?.dismiss(animated: true)
        }
        
        let retryActyion = UIAlertAction(title: L10n.Payment.alertRetry, style: .default) { [weak self] action in
            UIBlockingProgressHUD.show()
            self?.presenter.getCurrencies()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryActyion)
        alert.preferredAction = retryActyion
        present(alert, animated: true, completion: nil)
    }
    
    func showUnsuccesfullPaymentAlert() {
        UIBlockingProgressHUD.dismiss()
        let alert = UIAlertController(title: L10n.Payment.paymentAlertTitle, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n.Payment.alertCancel, style: .cancel, handler: nil)
        let retryActyion = UIAlertAction(title: L10n.Payment.alertRetry, style: .default) { [weak self] action in
            UIBlockingProgressHUD.show()
            self?.presenter.payOrder()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryActyion)
        alert.preferredAction = retryActyion
        present(alert, animated: true, completion: nil)
    }
    
    func showSucessfulPaymentScreen() {
        UIBlockingProgressHUD.dismiss()
        let successfulVC = SuccessfulPaymentViewController()
        successfulVC.delegate = self
        successfulVC.modalPresentationStyle = .overFullScreen
        present(successfulVC, animated: true)
    }
    
    func updateCurrencies() {
        currenciesCollectionView.reloadData()
        UIBlockingProgressHUD.dismiss()
    }
    
    private func updatePayButtonState() {
        payButton.isEnabled = pickedCurrencyIndex >= 0
        payButton.alpha = payButton.isEnabled == true ? 1 : 0.5
    }
    
    private func setupNavigationItem() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(resource: .backward), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.tintColor = Asset.ypBlack.color
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.title = L10n.Payment.navBarTitle
    }
    
    @objc
    private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    private func setupCurrenciesCollectionView() {
        currenciesCollectionView.register(CurrenciesCollectionViewCell.self, forCellWithReuseIdentifier: CurrenciesCollectionViewCell.identifier)
        
        currenciesCollectionView.allowsMultipleSelection = false
        currenciesCollectionView.backgroundColor = Asset.ypWhite.color
        currenciesCollectionView.dataSource = self
        currenciesCollectionView.delegate = self
        
        currenciesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currenciesCollectionView)
        
        NSLayoutConstraint.activate([
            currenciesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            currenciesCollectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -20),
            currenciesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            currenciesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupFooterView() {
        footerView.backgroundColor = Asset.ypLightGrey.color
        footerView.layer.cornerRadius = 16
        footerView.clipsToBounds = true
        
        let agreementLabel = UILabel()
        agreementLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        agreementLabel.textColor = Asset.ypBlack.color
        agreementLabel.text = L10n.Payment.agreementLabel
        
        agreementButton.backgroundColor = Asset.ypLightGrey.color
        agreementButton.setTitle(L10n.Payment.agreementLinkText, for: .normal)
        agreementButton.setTitleColor(Asset.ypBlue.color, for: .normal)
        agreementButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        agreementButton.addTarget(self, action: #selector(didTapAgreementButton), for: .touchUpInside)

        payButton.backgroundColor = Asset.ypBlack.color
        payButton.setTitle(L10n.Payment.pay, for: .normal)
        payButton.setTitleColor(Asset.ypWhite.color, for: .normal)
        payButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        payButton.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        payButton.layer.cornerRadius = 16
        payButton.clipsToBounds = true
        
        footerView.translatesAutoresizingMaskIntoConstraints = false
        agreementLabel.translatesAutoresizingMaskIntoConstraints = false
        agreementButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(footerView)
        footerView.addSubview(agreementLabel)
        footerView.addSubview(agreementButton)
        footerView.addSubview(payButton)
        
        NSLayoutConstraint.activate([
            footerView.heightAnchor.constraint(equalToConstant: 186),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            agreementLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16),
            agreementLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
        ])
        
        NSLayoutConstraint.activate([
            agreementButton.heightAnchor.constraint(equalToConstant: 26),
            agreementButton.topAnchor.constraint(equalTo: agreementLabel.bottomAnchor),
            agreementButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: 60),
            payButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            payButton.topAnchor.constraint(equalTo: agreementButton.bottomAnchor, constant: 16),
        ])
    }
    
    @objc
    private func didTapAgreementButton() {        
        presenter.openAgreementView()
    }
    
    @objc
    private func didTapPayButton() {
        UIBlockingProgressHUD.show()
        presenter.payOrder()
    }
}
    
extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrenciesCollectionViewCell.identifier, for: indexPath) as? CurrenciesCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.currency = presenter.currencies[indexPath.row]
        cell.isPicked = pickedCurrencyIndex == indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedCurrencyIndex = indexPath.row
        presenter.selectCurrencyByIndex(index: indexPath.row)
        updatePayButtonState()
        currenciesCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - sectionParams.paddingWidth
        let cellWidth =  availableWidth / CGFloat(sectionParams.cellCount)
        return CGSize(width: cellWidth,
                      height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionParams.topInset, left: sectionParams.leftInset, bottom: sectionParams.bottomInset, right: sectionParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionParams.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionParams.cellSpacing
    }
}

extension PaymentViewController: SuccessfulPaymentViewControllerDelegate {
    func successPayment() {
        presenter.orderPaymentCompletion()
        navigationController?.dismiss(animated: true)
        delegate?.returnToCatalogTab()
    }
}
