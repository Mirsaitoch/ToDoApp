//
//  TodoItemTests.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 21.06.2024.
//

import XCTest
@testable import ToDo_App

final class TodoItemTests: XCTestCase {
    
    //Тест на инициализацию
    func testTodoItemInitialization() {
        
        let todo = TodoItem(
            id: nil,
            text: "Test",
            importance: .important,
            isCompleted: false,
            createDate: Date()
        )
        
        // Проверка, что значения были присвоены корректно
        XCTAssertEqual(todo.text, "Test")
        XCTAssertEqual(todo.importance, .important)
        XCTAssertFalse(todo.isCompleted)
        XCTAssertNotNil(todo.createDate)
        XCTAssertNotNil(todo.id) // Проверка, что присвоился ID
        
        // Проверка, что значения не присвоены по умолчанию
        XCTAssertNil(todo.deadline)
        XCTAssertNil(todo.changeDate)
    }
    
    //Тест на добавление TodoItem в коллекцию
    func testFileCacheAddTodoItem() {
        let fileCache = FileCache()
        
        let todo = TodoItem(id: "1", text: "Test Add", importance: .usual, isCompleted: false, createDate: Date())
        
        fileCache.addTodoItem(todo)
        XCTAssertEqual(fileCache.toDoItems.count, 1)
        XCTAssertEqual(fileCache.toDoItems.first?.text, "Test Add")
    }
    
    //Тест на добавление двух TodoItem с одиннаковым id в коллекцию
    func testFileCacheAddTwoTodoItems() {
        let fileCache = FileCache()
        let todo1 = TodoItem(
            id: "1",
            text: "Test Add 1",
            importance: .usual,
            isCompleted: false,
            createDate: Date()
        )
        let todo2 = TodoItem(
            id: "1",
            text: "Test Add 2",
            importance: .usual,
            isCompleted: false,
            createDate: Date()
        )
        
        fileCache.addTodoItem(todo1)
        fileCache.addTodoItem(todo2)
        
        XCTAssertEqual(fileCache.toDoItems.count, 1)
    }
    
    //Тест на удаление TodoItem из коллекции
    func testFileCacheDeleteTodoItem() {
        let fileCache = FileCache()
        let todo1 = TodoItem(
            id: "1",
            text: "Test Delete 1",
            importance: .usual,
            isCompleted: false,
            createDate: Date()
        )
        let todo2 = TodoItem(
            id: "2",
            text: "Test Delete 2",
            importance: .usual,
            isCompleted: false,
            createDate: Date()
        )
        fileCache.addTodoItem(todo1)
        fileCache.addTodoItem(todo2)
        fileCache.deleteTodoItem("1")
        XCTAssertEqual(fileCache.toDoItems.count, 1)
        XCTAssertEqual(fileCache.toDoItems.first?.id, "2")
    }
    
    //Тест на сохранение и загрузку файлов
    func testFileCacheSaveLoadTodoItems() {
        let fileCache = FileCache()
        
        let todo = TodoItem(
            id: "1",
            text: "Test Save Load",
            importance: .important,
            isCompleted: false,
            createDate: Date()
        )
        
        fileCache.addTodoItem(todo)
        let fileName = "test_todos.json"
        fileCache.saveTodoItems(to: fileName)
        
        let newFileCache = FileCache()
        newFileCache.loadTodoItems(from: fileName)
        
        XCTAssertEqual(newFileCache.toDoItems.count, 1)
        XCTAssertEqual(newFileCache.toDoItems.first?.text, "Test Save Load")
        
    }
    
    //  Проверка конвертиции в CSV
    func testTodoItemToCSV() {
        let createDate = Date()
        let changeDate = Date()
        let todo = TodoItem(id: "123", text: "Task with, comma", importance: .important, deadline: nil, isCompleted: false, createDate: createDate, changeDate: changeDate)
        let csv = todo.toCSV()
        
        let expectedCSV = "123,\"Task with, comma\",important,,false,\(createDate.description),\(changeDate.description)"
        XCTAssertEqual(csv, expectedCSV)
    }
    
    //  Проверка конвертиции из CSV
    func testTodoItemFromCSV() {
        let createDate = Date()
        let changeDate = Date()
        
        let csvString = "123,\"Task with, comma\",important,,false,\(createDate.description),\(changeDate.description)"
        
        if let todo = TodoItem.fromCSV(csvString) {
            XCTAssertEqual(todo.id, "123")
            XCTAssertEqual(todo.text, "Task with, comma")
            XCTAssertEqual(todo.importance, .important)
            XCTAssertFalse(todo.isCompleted)
            
            let calendar = Calendar.current
            XCTAssertEqual(calendar.component(.year, from: todo.createDate), calendar.component(.year, from: createDate))
            XCTAssertEqual(calendar.component(.month, from: todo.createDate), calendar.component(.month, from: createDate))
            XCTAssertEqual(calendar.component(.day, from: todo.createDate), calendar.component(.day, from: createDate))
            XCTAssertEqual(calendar.component(.hour, from: todo.createDate), calendar.component(.hour, from: createDate))
            XCTAssertEqual(calendar.component(.minute, from: todo.createDate), calendar.component(.minute, from: createDate))
            XCTAssertEqual(calendar.component(.second, from: todo.createDate), calendar.component(.second, from: createDate))
            
            XCTAssertEqual(calendar.component(.year, from: todo.changeDate ?? Date()), calendar.component(.year, from: changeDate))
            XCTAssertEqual(calendar.component(.month, from: todo.changeDate ?? Date()), calendar.component(.month, from: changeDate))
            XCTAssertEqual(calendar.component(.day, from: todo.changeDate ?? Date()), calendar.component(.day, from: changeDate))
            XCTAssertEqual(calendar.component(.hour, from: todo.changeDate ?? Date()), calendar.component(.hour, from: changeDate))
            XCTAssertEqual(calendar.component(.minute, from: todo.changeDate ?? Date()), calendar.component(.minute, from: changeDate))
            XCTAssertEqual(calendar.component(.second, from: todo.changeDate ?? Date()), calendar.component(.second, from: changeDate))
            
        } else {
            XCTFail("Failed to parse CSV")
        }
    }
    
    func testParseCSV() {
        let createDate = Date()
        let changeDate = Date()
        let deadlineDate = Date()
        let createDateString = createDate.description
        let changeDateString = changeDate.description
        let deadlineDateString = deadlineDate.description

        let csvString = """
                123,"Task with, comma",important,,false,\(createDateString),\(changeDateString)
                124,"Task",usual,,true,\(createDateString),
                125,"👽",unimportant,\(deadlineDateString),false,\(createDateString),
                """
        
        let todos = TodoItem.parseCSV(csv: csvString)
        XCTAssertEqual(todos.count, 3)
        
        let todo1 = todos[0]
        XCTAssertEqual(todo1.id, "123")
        XCTAssertEqual(todo1.text, "Task with, comma")
        XCTAssertEqual(todo1.importance, .important)
        XCTAssertFalse(todo1.isCompleted)
        XCTAssertEqual(todo1.createDate.description, createDate.description)
        XCTAssertEqual(todo1.changeDate?.description, changeDate.description)
        
        let todo2 = todos[1]
        XCTAssertEqual(todo2.id, "124")
        XCTAssertEqual(todo2.text, "Task")
        XCTAssertEqual(todo2.importance, .usual)
        XCTAssertTrue(todo2.isCompleted)
        XCTAssertEqual(todo2.createDate.description, createDate.description)
        XCTAssertNil(todo2.changeDate)
        
        let todo3 = todos[2]
        XCTAssertEqual(todo3.id, "125")
        XCTAssertEqual(todo3.text, "👽")
        XCTAssertEqual(todo3.importance, .unimportant)
        XCTAssertEqual(todo3.deadline?.description, deadlineDate.description)
        XCTAssertFalse(todo3.isCompleted)
        XCTAssertEqual(todo3.createDate.description, createDate.description)
        XCTAssertNil(todo3.changeDate)
    }
    
}
