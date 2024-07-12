//  URLSession+DataTask.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 10.07.2024.
//

import CocoaLumberjackSwift
import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?
        let result = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
                task = self.dataTask(with: urlRequest) { data, response, error in
                    if Task.isCancelled {
                        DDLogError("Task is canceled")
                        continuation.resume(throwing: CancellationError())
                    }
                    if let error = error {
                        DDLogError("Error: \(error)")
                        continuation.resume(throwing: error)
                    } else if let data = data, let response = response {
                        DDLogInfo("Success dataTask")
                        continuation.resume(returning: (data, response))
                    } else {
                        DDLogError("Error: \(URLError(.badServerResponse))")
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                    return
                }
                if Task.isCancelled {
                    DDLogError("Task is canceled")
                    continuation.resume(throwing: CancellationError())
                    return
                }
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
        
        return result
    }
}
