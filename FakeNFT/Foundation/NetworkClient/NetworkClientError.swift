//
//  NetworkClientError.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import Foundation


enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
    case invalidBaseUrl
    case invalidUrl
    case invalidRequest
    case invalidRequestBody
}
