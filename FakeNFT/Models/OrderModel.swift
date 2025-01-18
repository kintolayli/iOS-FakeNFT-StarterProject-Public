//
//  OrderModel.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 06.01.2025.
//

import Foundation


struct OrderModel: Codable {
    let nfts: [UUID]
    let id: UUID
}
