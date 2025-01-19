//
//  NftDetailPresenterAlt.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 15.01.2025.
//

import Foundation

// MARK: - State

enum NftDetailStateAlt {
    case initial, loading, failed(Error), data
}

final class NftDetailPresenterImplAlt: NftDetailPresenter {

    // MARK: - Properties

    weak var view: NftDetailView?
    private let currentNft: NftModel
    private var state = NftDetailStateAlt.initial {
        didSet {
            stateDidChanged()
        }
    }

    // MARK: - Init

    init(currentNft: NftModel) {
        self.currentNft = currentNft
    }

    // MARK: - Functions

    func viewDidLoad() {
        state = .loading
    }

    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
            loadNft()
        case .data:
            view?.hideLoading()
            let cellModels = currentNft.images.map { NftDetailCellModel(url: $0) }
            view?.displayCells(cellModels)
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }

    private func loadNft() {
        self.state = .data
    }

    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = L10n.Error.network
        default:
            message = L10n.Error.unknown
        }

        let actionText = L10n.Error.repeat
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.state = .loading
        }
    }
}

