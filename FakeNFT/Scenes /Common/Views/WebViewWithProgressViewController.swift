//
//  WebViewWithProgressViewController.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import UIKit
import WebKit

final class WebViewWithProgressViewController: WebViewController {

    // MARK: - Properties

    private let progressView = UIProgressView(progressViewStyle: .default)
    private var progressObservation: NSKeyValueObservation?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        observeWebViewProgress()
        setupBackButton()
    }

    deinit {
        progressObservation?.invalidate()
    }

    // MARK: - Setup Methods

    private func setupBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .ypBlack

        navigationItem.leftBarButtonItem = backButton
    }

    private func setupProgressView() {
        progressView.tintColor = .ypBlueUniversal
        progressView.trackTintColor = .clear
        view.setupView(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func observeWebViewProgress() {
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self else { return }
            self.progressView.progress = Float(webView.estimatedProgress)
            self.progressView.isHidden = webView.estimatedProgress >= 1.0
        }
    }
}

// MARK: - Actions

extension WebViewWithProgressViewController {
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
