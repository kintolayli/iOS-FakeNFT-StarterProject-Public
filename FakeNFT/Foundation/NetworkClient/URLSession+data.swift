//
//  URLSession+data.swift
//  FakeNFT
//
//  Created by Ilya Lotnik on 25.12.2024.
//

import Foundation
import UIKit


extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let logMessage =
                    """
                    [\(String(describing: self)).\(#function)]:
                    NetworkError: HTTP status code: \(statusCode)
                    """
                    print(logMessage)
                    fulfillCompletionOnTheMainThread(.failure(NetworkClientError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                let logMessage =
                """
                [\(String(describing: self)).\(#function)]:
                NetworkError: \(error.localizedDescription)
                """
                print(logMessage)
                fulfillCompletionOnTheMainThread(.failure(NetworkClientError.urlRequestError(error)))
            } else {
                let logMessage =
                """
                [\(String(describing: self)).\(#function)]:
                NetworkError: URLSession error
                """
                print(logMessage)
                fulfillCompletionOnTheMainThread(.failure(NetworkClientError.urlSessionError))
            }
        })

        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable> (
        for request: URLRequest,
        completionHandler: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completionHandler(.success(object))
                } catch {
                    let logMessage =
                    """
                    [\(String(describing: self)).\(#function)]:
                    - Ошибка декодирования \(error.localizedDescription)
                    - Данные: \(String(data: data, encoding: .utf8) ?? "")
                    """
                    print(logMessage)

                    completionHandler(.failure(error))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
        return task
    }
}

