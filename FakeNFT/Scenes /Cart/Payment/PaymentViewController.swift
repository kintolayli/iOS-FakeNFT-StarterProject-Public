//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 18.12.2024.
//

import UIKit

struct GeometricParams {
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

final class PaymentViewController: UIViewController {
    private let currenciesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let footerView = UIView()
    private let agreementButton = UIButton()
    private let payButton = UIButton()
    
    private let currencies = CurrencyMocks.currencies
    private var pickedCurrencyIndex = -1
    
    private let sectionParams = GeometricParams(cellCount: 2,
                                                leftInset: 16,
                                                rightInset: 16,
                                                topInset: 0,
                                                bottomInset: 0,
                                                cellSpacing: 7,
                                                lineSpacing: 7
    )
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(resource: .ypWhite)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupFooterView()
        setupCurrenciesCollectionView()
    }
    
    private func setupNavigationItem() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(resource: .backward), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.tintColor = UIColor(resource: .ypBlack)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.title = "Выберите способ оплаты"
    }
    
    @objc
    private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    private func setupCurrenciesCollectionView() {
        currenciesCollectionView.register(CurrenciesCollectionViewCell.self, forCellWithReuseIdentifier: CurrenciesCollectionViewCell.identifier)
        
        currenciesCollectionView.allowsMultipleSelection = false
        currenciesCollectionView.backgroundColor = UIColor(resource: .ypWhite)
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
        footerView.backgroundColor = UIColor(resource: .ypLightGrey)
        footerView.layer.cornerRadius = 16
        footerView.clipsToBounds = true
        
        let agreementLabel = UILabel()
        agreementLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        agreementLabel.textColor = UIColor(resource: .ypBlack)
        agreementLabel.text = "Совершая покупку, вы соглашаетесь с условиями"
        
        agreementButton.backgroundColor = UIColor(resource: .ypLightGrey)
        agreementButton.setTitle("Пользовательского соглашения", for: .normal)
        agreementButton.setTitleColor(UIColor(resource: .ypBlue), for: .normal)
        agreementButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        agreementButton.addTarget(self, action: #selector(didTapAgreementButton), for: .touchUpInside)

        payButton.backgroundColor = UIColor(resource: .ypBlack)
        payButton.setTitle("Оплатить", for: .normal)
        payButton.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
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
        let agreementWebViewController = WebViewController()
        let agreementUrl = "https://yandex.ru/legal/practicum_termsofuse/"
        agreementWebViewController.load(urlString: agreementUrl)
        navigationController?.pushViewController(agreementWebViewController, animated: true)
    }
    
    @objc
    private func didTapPayButton() {
        
    }
}
    
extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrenciesCollectionViewCell.identifier, for: indexPath) as? CurrenciesCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.currency = currencies[indexPath.row]
        cell.isPicked = pickedCurrencyIndex == indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedCurrencyIndex = indexPath.row
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
    
