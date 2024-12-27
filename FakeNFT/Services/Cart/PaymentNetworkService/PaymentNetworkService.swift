//
//  PaymentNetworkService.swift
//  FakeNFT
//
//  Created by Виталий Фульман on 27.12.2024.
//

import Foundation

final class PaymentNetworkService {
    let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func putOrder(nfts: [String], orderId: String, completion: @escaping (Result<OrderItemDto, Error>) -> Void) {
        let dto = OrderParametersDto(nfts: nfts, orderId: orderId)
        let request = OrderPutRequest(dto: dto)
        
        networkClient.send(request: request, type: OrderItemDto.self) { result in
            DispatchQueue.main.async
            {
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getOrder(completion:@escaping (Result<OrderItemDto, Error>) -> Void) {
        let request = OrderGetRequest()
        
        networkClient.send(request: request, type: OrderItemDto.self) { result in
            DispatchQueue.main.async
            {
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func payOrderWithCurrencyId(currencyId: String, completion: @escaping (Result<PaymentItemDto, Error>) -> Void) {
        let request = PaymentGetRequest(currencyId: currencyId)
        
        networkClient.send(request: request, type: PaymentItemDto.self) { result in
            DispatchQueue.main.async
            {
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getCurrencies(completion:@escaping (Result<[CurrencyItemDto], Error>) -> Void) {
        let request = CurrenciesGetRequest()
        
        networkClient.send(request: request, type: [CurrencyItemDto].self) { result in
            DispatchQueue.main.async
            {
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
}
