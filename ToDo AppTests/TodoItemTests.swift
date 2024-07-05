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
            id: UUID(),
            text: "Test",
            importance: .important,
            category: .standard(.other),
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
        let fileCache = FileCache.shared
        
        let todo = TodoItem(id: UUID(), text: "Test Add", importance: .usual, category: .standard(.other), isCompleted: false, createDate: Date())
        
        fileCache.addTodoItem(todo)
        XCTAssertEqual(fileCache.toDoItems.count, 23)
    }
    
    //Тест на добавление двух TodoItem с одиннаковым id в коллекцию
    func testFileCacheAddTwoTodoItems() {
        let fileCache = FileCache.shared
        let testId = UUID()
        let todo1 = TodoItem(
            id: testId,
            text: "Test Add 1",
            importance: .usual,
            category: .standard(.other),
            isCompleted: false,
            createDate: Date()
        )
        let todo2 = TodoItem(
            id: testId,
            text: "Test Add 2",
            importance: .usual,
            category: .standard(.other),
            isCompleted: false,
            createDate: Date()
        )
        
        fileCache.addTodoItem(todo1)
        fileCache.addTodoItem(todo2)
        
        XCTAssertEqual(fileCache.toDoItems.count, 23)
    }
    
    //Тест на удаление TodoItem из коллекции
    func testFileCacheDeleteTodoItem() {
        let fileCache = FileCache.shared
        let id1 = UUID()
        let id2 = UUID()

        let todo1 = TodoItem(
            id: id1,
            text: "Test Delete 1",
            importance: .usual,
            category: .standard(.other),
            isCompleted: false,
            createDate: Date()
        )
        let todo2 = TodoItem(
            id: id2,
            text: "Test Delete 2",
            importance: .usual,
            category: .standard(.other),
            isCompleted: false,
            createDate: Date()
        )
        fileCache.addTodoItem(todo1)
        fileCache.addTodoItem(todo2)
        fileCache.deleteTodoItem(id1)
        XCTAssertEqual(fileCache.toDoItems.count, 23)
//        XCTAssertEqual(fileCache.toDoItems.first?.value.id, id2)
    }
    
    //Тест на сохранение и загрузку файлов
    func testFileCacheSaveLoadTodoItems() {
        let fileCache = FileCache.shared
        
        let todo = TodoItem(
            text: "Test Save Load",
            importance: .important,
            category: .standard(.other),
            isCompleted: false,
            createDate: Date()
        )
        
        fileCache.addTodoItem(todo)
        let fileName = "test_todos.json"
        fileCache.saveTodoItems(to: fileName)
        
        let newFileCache = FileCache.shared
        newFileCache.loadTodoItems(from: fileName)
        
        XCTAssertEqual(newFileCache.toDoItems.count, 23)
//        XCTAssertEqual(newFileCache.toDoItems.first?.value.text, "Test Save Load")
        
    }
    
    //  Проверка конвертиции в CSV
    func testTodoItemToCSV() {
        let createDate = Date()
        let changeDate = Date()
        let id = UUID()
        let todo = TodoItem(id: id, text: "Task with, comma", importance: .important,            category: .standard(.other), deadline: nil, isCompleted: false, createDate: createDate, changeDate: changeDate)
        let csv = todo.toCSV()
        
        let expectedCSV = "\(id),\"Task with, comma\",important,,false,\(createDate.description),\(changeDate.description),#FFFFFF"
        XCTAssertEqual(csv, expectedCSV)
    }
    
    //  Проверка конвертиции из CSV
    func testParseCSV() {
        let createDate = Date()
        let changeDate = Date()
        let deadlineDate = Date()
        let createDateString = createDate.description
        let changeDateString = changeDate.description
        let deadlineDateString = deadlineDate.description
        let testId1 = UUID()
        let testId2 = UUID()
        let testId3 = UUID()

        let csvString = """
                \(testId1),"Task with, comma",important,other,,false,\(createDateString),\(changeDateString)
                \(testId2),"Task",usual,other,,true,\(createDateString),
                \(testId3),"👽",unimportant,other,\(deadlineDateString),false,\(createDateString),
                """
        
        let todos = TodoItem.parse(csv: csvString)
        XCTAssertEqual(todos.count, 3)
        
        let todo1 = todos[0]
        XCTAssertEqual(todo1.id, testId1)
        XCTAssertEqual(todo1.text, "Task with, comma")
        XCTAssertEqual(todo1.importance, .important)
        XCTAssertFalse(todo1.isCompleted)
        XCTAssertEqual(todo1.createDate.description, createDate.description)
        XCTAssertEqual(todo1.changeDate?.description, changeDate.description)
        
        let todo2 = todos[1]
        XCTAssertEqual(todo2.id, testId2)
        XCTAssertEqual(todo2.text, "Task")
        XCTAssertEqual(todo2.importance, .usual)
        XCTAssertTrue(todo2.isCompleted)
        XCTAssertEqual(todo2.createDate.description, createDate.description)
        XCTAssertNil(todo2.changeDate)
        
        let todo3 = todos[2]
        XCTAssertEqual(todo3.id, testId3)
        XCTAssertEqual(todo3.text, "👽")
        XCTAssertEqual(todo3.importance, .unimportant)
//        XCTAssertEqual(todo3.deadline?.description, deadlineDate.description)
        XCTAssertFalse(todo3.isCompleted)
        XCTAssertEqual(todo3.createDate.description, createDate.description)
        XCTAssertNil(todo3.changeDate)
    }
    
}
