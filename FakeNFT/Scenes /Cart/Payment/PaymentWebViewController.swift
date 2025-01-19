//
//  PaymentWebViewController.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 25.12.2024.
//

import UIKit
import WebKit

final class PaymentWebViewController: UIViewController, WKNavigationDelegate {
    private let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.ypWhite.color
        webView.navigationDelegate = self
        setupNavigationItem()
        setupWebViewController()
    }
    
    private func setupWebViewController() {
        webView.allowsBackForwardNavigationGestures = true
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationItem() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(resource: .backward), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.tintColor = Asset.ypBlack.color
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func load(urlString: String) {
        guard let url = URL(string: urlString)
        else {
            print("\(#file):\(#function): Can not create URL from string: \(urlString)")
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    @objc
    private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
}
