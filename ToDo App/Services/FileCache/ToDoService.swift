//
//  ToDoItemService.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 18.07.2024.
//

import Foundation

class ToDoService: @unchecked Sendable {
    
    let networkingService: NetworkingService
    
    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }
    
    // Получение списка задач
    func fetchTodoList() async throws -> TodoListResponse {
        let url = try networkingService.makeUrl(path: "/todo/list")
        let (data, _) = try await networkingService.getData(url: url)
        return try JSONDecoder().decode(TodoListResponse.self, from: data)
    }
    
    // Обновление списка задач
    func updateTodoList(tasks: [TodoItem], revision: Int) async throws -> TodoListResponse {
        let url = try networkingService.makeUrl(path: "/todo/list")
        let todoBody = TodoListRequest(list: tasks)
        let body = try JSONEncoder().encode(todoBody)
        let (data, _) = try await networkingService.patchData(url: url, body: body, revision: revision)
        return try JSONDecoder().decode(TodoListResponse.self, from: data)
    }
    
    // Получение задачи по id
    func fetchTodoItem(by id: UUID) async throws -> TodoResponse {
        let url = try networkingService.makeUrl(path: "/todo/list/\(id)")
        let (data, _) = try await networkingService.getData(url: url)
        return try JSONDecoder().decode(TodoResponse.self, from: data)
    }
    
    // Добавление новой задачи
    func addTodoItem(_ todo: TodoItem, revision: Int) async throws -> TodoResponse {
        let url = try networkingService.makeUrl(path: "/todo/list")
        let todoBody = TodoRequest(element: todo)
        let body = try JSONEncoder().encode(todoBody)
        let (data, _) = try await networkingService.postData(url: url, body: body, revision: revision)
        return try JSONDecoder().decode(TodoResponse.self, from: data)
    }
    
    // Обновление существующей задачи
    func updateTodoItem(_ todo: TodoItem, revision: Int) async throws -> TodoResponse {
        let url = try networkingService.makeUrl(path: "/todo/list/\(todo.id)")
        let todoBody = TodoRequest(element: todo)
        let body = try JSONEncoder().encode(todoBody)
        let (data, _) = try await networkingService.putData(url: url, body: body, revision: revision)
        return try JSONDecoder().decode(TodoResponse.self, from: data)
    }
    
    // Удаление задачи
    func deleteTodoItem(by id: UUID, revision: Int) async throws -> TodoResponse {
        let url = try networkingService.makeUrl(path: "/todo/list/\(id)")
        do {
            let (data, response) = try await networkingService.deleteData(url: url, revision: revision)
            let httpResponse = response
            switch httpResponse.statusCode {
            case 200...299:
                return try JSONDecoder().decode(TodoResponse.self, from: data)
            case 400:
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                throw ToDoServiceError.badRequest(errorMessage.message)
            case 401:
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                throw ToDoServiceError.unauthorized(errorMessage.message)
            case 404:
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                throw ToDoServiceError.notFound(errorMessage.message)
            case 500:
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                throw ToDoServiceError.serverError(errorMessage.message)
            default:
                let errorMessage = try JSONDecoder().decode(ErrorMessage.self, from: data)
                throw ToDoServiceError.unknown(errorMessage.message)
            }
        } catch {
            throw ToDoServiceError.unknown("Unknown error occurred.")
        }
    }
}
