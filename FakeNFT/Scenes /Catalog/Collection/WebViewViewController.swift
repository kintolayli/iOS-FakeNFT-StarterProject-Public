//
//  WebViewViewController.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 07.01.2025.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}


final class WebViewViewController: UIViewController & WebViewViewControllerProtocol, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.accessibilityIdentifier = "NFTAuthorhWebView"
        return webView
    }()
    
    private let progressView: UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.progressTintColor = Asset.ypBlack.color
        return progressBar
    }()
    
    var presenter: WebViewPresenterProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        
        setupUI()
        setupObserver()
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    private func setupObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else {
                     return
                 }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [webView, progressView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            
        ])
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
