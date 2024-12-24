//
//  UserDefaults+Extensio.swift
//  FakeNFT
//
//  Created by  Admin on 18.12.2024.
//

import Foundation

enum SortType: String {
    case price
    case rating
    case name
    case quantity
}

extension UserDefaults {
    private enum Keys {
        static let nftSortType = "nftSortType"
        static let statisticSortType = "statisticSortType"
        static let catalogSortType = "catalogSortType"
    }
    
    func saveSortType(_ sortType: SortType) {
        set(sortType.rawValue, forKey: Keys.nftSortType)
    }
    
    func loadSortType() -> SortType? {
        if let sortTypeString = string(forKey: Keys.nftSortType),
           let sortType = SortType(rawValue: sortTypeString) {
            return sortType
        } else {
            return .rating
        }
    }
}
