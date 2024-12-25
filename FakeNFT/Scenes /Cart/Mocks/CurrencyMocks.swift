//
//  CurrencyMocks.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 24.12.2024.
//

struct CurrencyMocks {
    static let currencies: [Currency] = [
        Currency(title: "Shiba_Inu",
                 name: "SHIB",
                 image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Shiba_Inu_(SHIB).png",
                 id: "0"),
        Currency(title: "Cardano",
                 name: "ADA",
                 image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Cardano_(ADA).png",
                 id: "1"),
        Currency(title: "Tether",
                 name: "USDT",
                 image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Tether_(USDT).png",
                 id: "2"),
        Currency(title: "ApeCoin",
                 name: "APE",
                 image: "https://code.s3.yandex.net/Mobile/iOS/Currencies/ApeCoin_(APE).png",
                 id: "3")
    ]
}
