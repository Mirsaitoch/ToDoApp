//
//  DefaultNetworkingService.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 18.07.2024.
//

import Foundation
import SwiftUI

enum NetworkingError: Error {
    case noData
    case wrongURL(URLComponents)
}

enum RequestError: Error {
    case unexpectedResponse(URLResponse)
    case failedResponse(HTTPURLResponse)
}

enum ToDoServiceError: Error {
    case badRequest(String)
    case unauthorized(String)
    case notFound(String)
    case serverError(String)
    case unknown(String)
}

class DefaultNetworkingService: NetworkingService {
        
    private let token: String
    private static let httpStatusCodeSuccess = 200..<300
    
    init(token: String) {
        self.token = token
    }
    
    func makeUrl(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "hive.mrdekk.ru"
        components.path = path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkingError.wrongURL(components)
        }
        return url
    }
    
    private func performRequest(url: URL, method: String, body: Data? = nil, headers: [String: String]? = nil, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        
        var request = URLRequest(url: url, timeoutInterval: 60)
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = body
//            print("Response Data: \(String(data: body, encoding: .utf8) ?? "Unable to decode response")")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RequestError.unexpectedResponse(response)
        }
        
        guard Self.httpStatusCodeSuccess.contains(httpResponse.statusCode) else {
            throw RequestError.failedResponse(httpResponse)
        }
        
        return (data, httpResponse)
    }
    
    func getData(url: URL, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        return try await performRequest(url: url, method: "GET", urlSession: urlSession)
    }
    
    func postData(url: URL, body: Data, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        let headers = ["X-Last-Known-Revision": "\(revision)"]
        return try await performRequest(url: url, method: "POST", body: body, headers: headers, urlSession: urlSession)
    }
    
    func putData(url: URL, revision: Int, body: Data, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        let headers = ["X-Last-Known-Revision": "\(revision)"]
        return try await performRequest(url: url, method: "PUT", body: body, headers: headers, urlSession: urlSession)
    }
    
    func deleteData(url: URL, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        let headers = ["X-Last-Known-Revision": "\(revision)"]
        return try await performRequest(url: url, method: "DELETE", headers: headers, urlSession: urlSession)
    }
    
    func patchData(url: URL, body: Data, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        let headers = ["X-Last-Known-Revision": "\(revision)"]
        return try await performRequest(url: url, method: "PATCH", body: body, headers: headers, urlSession: urlSession)
    }
}
