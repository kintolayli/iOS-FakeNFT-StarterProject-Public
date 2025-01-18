//
//  NftCellProtocol.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

protocol NFTCellProtocol: AnyObject {
    func configure(with nft: NFT, isLiked: Bool, priceText: String, currencyText: String, onLikeButtonTap: @escaping (NFT) -> Void)
    func completeLikeUpdate()
    func revertLikeUpdate(isLiked: Bool)
}
