//
//  DataTaskTests.swift
//  ToDo AppTests
//
//  Created by Мирсаит Сабирзянов on 12.07.2024.
//

import XCTest
@testable import ToDo_App

class DataTaskTests: XCTestCase {

    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
        urlSession = URLSession(configuration: .default)
    }
    
    override func tearDown() {
        urlSession = nil
        super.tearDown()
    }

    func testSuccessfulResponse() async {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, response) = try await urlSession.dataTask(for: urlRequest)
            XCTAssertNotNil(data, "Data should not be nil")
            XCTAssertNotNil(response, "Response should not be nil")
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200, "Status code should be 200")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testErrorResponse() async {
        let url = URL(string: "https://jsonplaceholder.code.com")!
        let urlRequest = URLRequest(url: url)
        
        do {
            _ = try await urlSession.dataTask(for: urlRequest)
            XCTFail("Expected error but got success")
        } catch {
            XCTAssertNotNil(error, "Error should not be nil")
        }
    }
    
    func testCancellation() async {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
        let urlRequest = URLRequest(url: url)
        
        let task = Task {
            do {
                _ = try await urlSession.dataTask(for: urlRequest)
                XCTFail("Expected cancellation but got success")
            } catch {
                XCTAssertTrue((error as? CancellationError) != nil, "Error should be a CancellationError")
            }
        }
        
        task.cancel()
        
        await task.value
    }
}
