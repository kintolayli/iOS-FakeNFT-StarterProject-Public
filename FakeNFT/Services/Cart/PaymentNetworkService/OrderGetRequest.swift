//
//  OrderGetRequest.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 27.12.2024.
//

import Foundation

struct OrderGetRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod = .get
    var dto: Dto?
}
