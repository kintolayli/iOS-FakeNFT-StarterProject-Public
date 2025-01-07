//
//  NFTModel.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 04.01.2025.
//

import Foundation


struct NFTModel: Codable, Hashable {
    let createdAt: String
    let name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Double
    let author: URL
    let id: UUID
}
