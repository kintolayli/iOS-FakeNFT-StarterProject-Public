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
    
    private let currencies = CurrencyMocks.currencies
    
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
        navigationController?.popViewController(animated: true)
    }
    
    private func setupCurrenciesCollectionView() {
        currenciesCollectionView.register(CurrenciesCollectionViewCell.self, forCellWithReuseIdentifier: CurrenciesCollectionViewCell.identifier)
        
        currenciesCollectionView.allowsMultipleSelection = false
        currenciesCollectionView.backgroundColor = UIColor(resource: .ypBlue)
        
        currenciesCollectionView.dataSource = self
        currenciesCollectionView.delegate = self
        
        currenciesCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        currenciesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(currenciesCollectionView)
        
        NSLayoutConstraint.activate([
            currenciesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            currenciesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            currenciesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            currenciesCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
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
        
        return cell
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
    
