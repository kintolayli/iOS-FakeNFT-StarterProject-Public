//
//  SuccessfulPaymentViewController.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 25.12.2024.
//

protocol SuccessfulPaymentViewControllerDelegate: AnyObject {
    func successPayment()
}


import UIKit

final class SuccessfulPaymentViewController: UIViewController {
    weak var delegate: SuccessfulPaymentViewControllerDelegate?
    
    private let nftImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let purchaseView = UIView()
    private let returnToCatalogButton = UIButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(resource: .ypWhite)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPurchaseView()
        setupReturnToCatalogButton()
    }
    
    private func setupReturnToCatalogButton() {
        returnToCatalogButton.backgroundColor = UIColor(resource: .ypBlack)
        returnToCatalogButton.setTitle("Вернуться в каталог", for: .normal)
        returnToCatalogButton.setTitleColor(UIColor(resource: .ypWhite), for: .normal)
        returnToCatalogButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        returnToCatalogButton.addTarget(self, action: #selector(didTapReturnToCatalogButton), for: .touchUpInside)
        returnToCatalogButton.layer.cornerRadius = 16
        returnToCatalogButton.clipsToBounds = true
        
        returnToCatalogButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(returnToCatalogButton)
        
        NSLayoutConstraint.activate([
            returnToCatalogButton.heightAnchor.constraint(equalToConstant: 60),
            returnToCatalogButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            returnToCatalogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            returnToCatalogButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    @objc
    private func didTapReturnToCatalogButton() {
        dismiss(animated: false)
        delegate?.successPayment()
    }
    
    private func setupPurchaseView() {
        let succesfullPaymentImage = UIImage(resource: .succesfullPayment)
        nftImageView.image = succesfullPaymentImage
        
        greetingLabel.text = "Успех! Оплата прошла, поздравляем с покупкой!"
        greetingLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        greetingLabel.textColor = UIColor(resource: .ypBlack)
        greetingLabel.numberOfLines = 2
        greetingLabel.textAlignment = .center
        
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        purchaseView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(purchaseView)
        purchaseView.addSubview(nftImageView)
        purchaseView.addSubview(greetingLabel)
        
        NSLayoutConstraint.activate([
            nftImageView.widthAnchor.constraint(equalToConstant: 278),
            nftImageView.heightAnchor.constraint(equalToConstant: 278),
            nftImageView.centerXAnchor.constraint(equalTo: purchaseView.centerXAnchor),
            nftImageView.topAnchor.constraint(equalTo: purchaseView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            greetingLabel.widthAnchor.constraint(equalToConstant: 303),
            greetingLabel.heightAnchor.constraint(equalToConstant: 56),
            greetingLabel.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 20),
            greetingLabel.centerXAnchor.constraint(equalTo: purchaseView.centerXAnchor),
            greetingLabel.leadingAnchor.constraint(equalTo: purchaseView.leadingAnchor),
            greetingLabel.trailingAnchor.constraint(equalTo: purchaseView.trailingAnchor),
            greetingLabel.bottomAnchor.constraint(equalTo: purchaseView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            purchaseView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            purchaseView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
