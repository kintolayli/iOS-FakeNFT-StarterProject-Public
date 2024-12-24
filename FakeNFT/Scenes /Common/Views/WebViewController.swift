//
//  WebViewController.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    // MARK: Private Properties

    private let url: String

    private lazy var loading: UIActivityIndicatorView = {
        let activityIndicator  = UIActivityIndicatorView()
        activityIndicator.center = view.center
        activityIndicator.style = .large
        return activityIndicator
    }()

    // MARK: - UI Components

    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    // MARK: - Initializers

    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .background
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateURL()
    }

    // MARK: - Private Functions

    private func updateURL() {
        guard let myURL = URL(string: url) else { return }
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
}

extension WebViewController {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loading.stopAnimating()
    }

    private func setNavigationItem() {
        self.navigationController?.navigationBar.tintColor = .ypBlack
    }
}

// MARK: - Extension: View Layout

extension WebViewController {
    func setupUI() {
        view.addSubview(webView)
        webView.addSubview(loading)
        loading.startAnimating()
        webView.navigationDelegate = self
        loading.hidesWhenStopped = true
        loading.constraintCenters(to: webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
