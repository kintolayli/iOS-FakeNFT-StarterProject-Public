//
//  MyNftStorage.swift
//  FakeNFT
//
//  Created by  Admin on 26.12.2024.
//

import Foundation

protocol MyNftStorage: AnyObject {
    func saveNft(_ nft: NFT)
    func getNft(with id: String) -> NFT?
}

final class MyNftStorageImpl: MyNftStorage {

    // MARK: - Private Properties

    private var storage: [String: NFT] = [:]

    private let syncQueue = DispatchQueue(label: "sync-nft-queue")

    // MARK: - Public Methods

    func saveNft(_ nft: NFT) {
        syncQueue.async { [weak self] in
            self?.storage[nft.id] = nft
        }
    }

    func getNft(with id: String) -> NFT? {
        syncQueue.sync {
            storage[id]
        }
    }
}
