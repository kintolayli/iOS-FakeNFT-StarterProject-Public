//
//  OrderPutRequest.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 27.12.2024.
//

import Foundation

struct OrderPutRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?
}

struct OrderParametersDto: Dto {
    let nfts: [String]
    let orderId: String
    
    func asDictionary() -> [String: String] {
        let nftsString = nfts.joined(separator: "&nfts=")
        return ["nfts": nftsString, "id": orderId]
    }
}
