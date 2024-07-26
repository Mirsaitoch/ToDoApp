//
//  FileCacheSwiftDataTests.swift
//  ToDo AppTests
//
//  Created by Мирсаит Сабирзянов on 25.07.2024.
//

import XCTest
@testable import ToDo_App

@MainActor
final class FileCacheTests: XCTestCase {
    
    var fileCache: FileCache!
    
    override func setUp() {
        super.setUp()
        fileCache = FileCache()
    }

    override func tearDown() {
        fileCache = nil
        super.tearDown()
    }

    func testInsertTodoItem() {
        let todoItem = TodoItemModel(text: "Test Todo", importance: .basic)
        fileCache.insert(todoItem)

        let fetchedItems = fileCache.fetch()
        XCTAssertTrue(fetchedItems.contains(where: { $0.uuid == todoItem.uuid }), "Inserted item should be in the fetched items")
    }

    func testDeleteTodoItem() {
        let todoItem = TodoItemModel(text: "Test Todo", importance: .basic)
        fileCache.insert(todoItem)
        
        fileCache.delete(todoItem)
        let fetchedItems = fileCache.fetch()
        XCTAssertFalse(fetchedItems.contains(where: { $0.uuid == todoItem.uuid }), "Deleted item should not be in the fetched items")
    }

    func testUpdateTodoItem() {
            let todoItem = TodoItemModel(text: "Test Todo", importance: .basic)
            fileCache.insert(todoItem)

            let updatedItem = TodoItemModel(
                uuid: todoItem.uuid,
                text: "Updated Test Todo",
                importance: .important,
                deadline: todoItem.deadline,
                done: todoItem.done,
                color: todoItem.color,
                changedAt: Date(),
                files: todoItem.files
            )

            fileCache.update(updatedItem)

            let fetchedItems = fileCache.fetch()

            XCTAssertTrue(
                fetchedItems.contains(where: {
                    $0.uuid == updatedItem.uuid &&
                    $0.text == "Updated Test Todo" &&
                    $0.importance == .important
                }),
                "Updated item should be in the fetched items with updated text and importance"
            )
        }
    func testAddTodoItem() {
        let todoItem = TodoItem(text: "Test Todo", importance: .basic)
        fileCache.addTodoItem(todoItem)
        
        XCTAssertEqual(fileCache.toDoItems[todoItem.id]?.text, todoItem.text, "Todo item should be added to in-memory storage")
    }

    func testDeleteTodoItemFromMemory() {
        let todoItem = TodoItem(text: "Test Todo", importance: .basic)
        fileCache.addTodoItem(todoItem)
        fileCache.deleteTodoItem(todoItem.id)
        
        XCTAssertNil(fileCache.toDoItems[todoItem.id], "Todo item should be deleted from in-memory storage")
    }
    
}
