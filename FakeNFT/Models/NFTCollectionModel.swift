//
//  CatalogModel.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 24.12.2024.
//

import Foundation


struct NFTCollectionModel: Codable, Hashable {
    let createdAt: String
    let name: String
    let cover: URL
    let nfts: [UUID]
    let description, author: String
    let id: UUID
}
