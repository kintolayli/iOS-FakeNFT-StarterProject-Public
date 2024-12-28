//
//  PaymentItemDto.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 27.12.2024.
//

struct PaymentItemDto: Decodable {
    let success: Bool
    let orderId: String
    let id: String
}
