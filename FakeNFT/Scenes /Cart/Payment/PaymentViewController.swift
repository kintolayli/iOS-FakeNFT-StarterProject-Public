//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 18.12.2024.
//

import UIKit

final class PaymentViewController: UIViewController {
    private let servicesAssembly: ServicesAssembly

    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor(resource: .ypWhite)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}