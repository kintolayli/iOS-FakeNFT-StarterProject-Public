//
//  PaymentGetRequest.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 27.12.2024.
//

import Foundation

struct PaymentParametersDto: Dto {
    let currencyId: String
    
    func asDictionary() -> [String: String] {
        return ["currencyId": currencyId]
    }
}

struct PaymentGetRequest: NetworkRequest {
    let currencyId: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyId)")
    }
    var httpMethod: HttpMethod = .get
    var dto: Dto?
}


