//
//  CatalogRequest.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 24.12.2024.
//

import Foundation


struct CatalogsRequest: NetworkRequest {
   var endpoint: URL? {
       URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
   }
    var httpMethod: HttpMethod = .get
   var dto: Dto?
}
