//
//  WebViewPresenter.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 07.01.2025.
//

import Foundation


public protocol WebViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
}

final class WebViewPresenter: WebViewPresenterProtocol {

    weak var view: WebViewViewControllerProtocol?
    private var request: URLRequest?

    init(stringUrl: String) {
        guard let url = URL(string: stringUrl) else { return }
        self.request = URLRequest(url: url)
    }

    func viewDidLoad() {
        guard let request = request else { return }

        view?.load(request: request)
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1) <= 0.0001
    }
}
