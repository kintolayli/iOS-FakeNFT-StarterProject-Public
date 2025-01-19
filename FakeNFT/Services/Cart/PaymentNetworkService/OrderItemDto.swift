//
//  OrderItemDto.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 27.12.2024.
//

struct OrderItemDto: Decodable {
    let nfts: [String]
    let id: String
}
