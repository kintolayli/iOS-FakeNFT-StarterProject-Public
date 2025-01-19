//
//  ProfileModel.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 06.01.2025.
//

import Foundation


struct ProfileModel: Codable {
    let name: String
    let avatar: URL
    let description: String
    let website: URL
    let nfts: [UUID]
    let likes: [UUID]
    let id: UUID
}
