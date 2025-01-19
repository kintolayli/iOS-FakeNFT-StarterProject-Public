//
//  Profile.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

struct Profile: Codable {
    let name: String
    let avatar: String?
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]
    let id: String
    
    init(
        name: String,
        avatar: String?,
        description: String,
        website: String,
        nfts: [String],
        likes: [String],
        id: String
    ) {
        self.name = name
        self.avatar = avatar
        self.description = description
        self.website = website
        self.nfts = nfts
        self.likes = likes
        self.id = id
    }
    
    init(from statistic: Statistic) {
        self.name = statistic.name
        self.avatar = statistic.avatar
        self.description = statistic.description ?? ""
        self.website = statistic.website
        self.nfts = statistic.nfts
        self.likes = []
        self.id = statistic.id
    }
    
    init() {
        self.name = ""
        self.avatar =  nil
        self.description = ""
        self.website = ""
        self.nfts = []
        self.likes = []
        self.id = ""
    }
}
