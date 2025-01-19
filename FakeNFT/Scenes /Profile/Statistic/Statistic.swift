//
//  Statistic.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

struct Statistic: Decodable {
    let name: String
    let avatar: String
    let description: String?
    let website: String
    let nfts: [String]
    let rating: String
    let id: String
}

typealias User = Statistic
