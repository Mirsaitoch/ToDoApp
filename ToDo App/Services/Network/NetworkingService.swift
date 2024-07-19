//
//  NetworkingService.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 18.07.2024.
//

import Foundation

protocol NetworkingService {
    func getData(url: URL, urlSession: URLSession) async throws -> (Data, HTTPURLResponse)
    func postData(url: URL, body: Data, revision: Int, urlSession: URLSession) async throws -> (Data, HTTPURLResponse)
    func putData(url: URL, revision: Int, body: Data, urlSession: URLSession) async throws -> (Data, HTTPURLResponse)
    func deleteData(url: URL, revision: Int, urlSession: URLSession) async throws -> (Data, HTTPURLResponse)
    func patchData(url: URL, body: Data, revision: Int, urlSession: URLSession) async throws -> (Data, HTTPURLResponse)
    func makeUrl(path: String, queryItems: [URLQueryItem]?) throws -> URL
}

extension NetworkingService {
    
    func getData(url: URL, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        return try await getData(url: url, urlSession: urlSession)
    }
    
    func postData(url: URL, body: Data, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        return try await postData(url: url, body: body, revision: revision, urlSession: urlSession)
    }
    
    func putData(url: URL, body: Data, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        return try await putData(url: url, revision: revision, body: body, urlSession: urlSession)
    }
    
    func deleteData(url: URL, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        return try await deleteData(url: url, revision: revision, urlSession: urlSession)
    }
    
    func patchData(url: URL, body: Data, revision: Int, urlSession: URLSession = .shared) async throws -> (Data, HTTPURLResponse) {
        return try await patchData(url: url, body: body, revision: revision, urlSession: urlSession)
    }
    
    func makeUrl(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        return try makeUrl(path: path, queryItems: queryItems)
    }
}
