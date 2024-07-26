//
//  TodoItemListViewModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//

import Foundation
import SwiftUI
import Combine
import CocoaLumberjackSwift

extension TodoItemList {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var items: [UUID: TodoItem] = [:]
        @Published var filtredItems: [TodoItem] = []
        @Published var selectedItem: TodoItem?
        @Published var showDetailView = false
        @Published var showCalendarView = false
        @Published var currentSortOption: SortOption = .byDate
        @Published var newItemText = ""
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var isDirty: Bool = false
                
        private let toDoService: ToDoService
        private var revisionValue = RevisionValue.shared
//        var fileCache = FileCache.shared
        var completedCount = 0
        private var cancellables: Set<AnyCancellable> = []
        var showCompleted = true
        var firstInit = true
        
        init(toDoService: ToDoService) {
            self.toDoService = toDoService
        }
        
        // MARK: - GET TodoItems
        func fetchTasks() async throws {
            items = [:]
            isLoading = true
            defer { isLoading = false }
            
            if isDirty {
                Task {
                    do {
                        try await updateTodoList()
                    } catch {
                        DDLogError("Failed to update the task list")
                    }
                }
            }
            
            var retryCount = 0
            let maxRetries = 3
            
            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.fetchTodoList()
                    DispatchQueue.main.async {
                        for item in response.list {
                            self.items[item.id] = item
                        }
                        /// сортировка задач
                        self.updateFilteredItems()
                        self.revisionValue.setRevision(response.revision)
                        self.isDirty = false
                        DDLogInfo("The tasks have been successfully received. Revision: \(response.revision)")
                    }
                    return
                } catch {
                    retryCount += 1
                    let seconds = 3
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                }
            }
            isDirty = true
            throw ToDoServiceError.unknown("Failed to fetch task after \(maxRetries) attempts.")
        }
        
        // MARK: - DELETE TodoItem
        func deleteItem(id: UUID) async throws {
            isLoading = true
            defer { isLoading = false }
            
            if isDirty {
                Task {
                    do {
                        try await updateTodoList()
                    } catch {
                        DDLogError("Failed to update the task list")
                    }
                }
            }
            
            var retryCount = 0
            let maxRetries = 3
            
            deleteTodo(id: id)

            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.deleteTodoItem(by: id, revision: revisionValue.getRevision())
                    revisionValue.setRevision(response.revision)
                    updateFilteredItems()
                    self.isDirty = false
                    DDLogInfo("The task was successfully deleted. Revision: \(response.revision)")
                    return
                } catch let error as ToDoServiceError {
                    switch error {
                    case .badRequest(let message):
                        DDLogError("Bad Request: \(message)")
                    case .unauthorized(let message):
                        DDLogError("Unauthorized: \(message)")
                    case .notFound(let message):
                        DDLogError("Not Found: \(message)")
                    case .serverError(let message):
                        DDLogError("Server Error: \(message)")
                    case .unknown(let message):
                        DDLogError("Unknown Error: \(message)")
                    }
                    retryCount += 1
                    let seconds = 1
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                } catch {
                    DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                    retryCount += 1
                    let seconds = 1
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                }
            }
            
            isDirty = true
            throw ToDoServiceError.unknown("Failed to delete task after \(maxRetries) attempts.")
        }
        
        // MARK: - ADD TodoItem
        func addItem(text: String) async throws {
            isLoading = true
            defer { isLoading = false }
            
            if isDirty {
                Task {
                    do {
                        try await updateTodoList()
                    } catch {
                        DDLogError("Failed to update the task list")
                    }
                }
            }
            
            let newItem = TodoItem(text: text)
            
            var retryCount = 0
            let maxRetries = 3

            addTodo(todo: newItem)

            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.addTodoItem(newItem, revision: revisionValue.getRevision())
                    updateFilteredItems()
                    revisionValue.setRevision(response.revision)
                    isDirty = false
                    DDLogInfo("The task has been successfully added. Revision: \(response.revision)")
                    return
                } catch let error as ToDoServiceError {
                    switch error {
                    case .badRequest(let message):
                        DDLogError("Bad Request: \(message)")
                        errorMessage = "Bad Request: \(message)"
                    case .unauthorized(let message):
                        DDLogError("Unauthorized: \(message)")
                        errorMessage = "Unauthorized: \(message)"
                    case .notFound(let message):
                        DDLogError("Not Found: \(message)")
                        errorMessage = "Not Found: \(message)"
                    case .serverError(let message):
                        DDLogError("Server Error: \(message)")
                        errorMessage = "Server Error: \(message)"
                    case .unknown(let message):
                        DDLogError("Unknown Error: \(message)")
                        errorMessage = "Unknown Error: \(message)"
                    }
                    retryCount += 1
                    let seconds = 1
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                } catch {
                    DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                    errorMessage = "Unexpected Error: \(error.localizedDescription)"
                    retryCount += 1
                    let seconds = 1
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                }
            }
            
            isDirty = true
            
            throw ToDoServiceError.unknown("Failed to add task after \(maxRetries) attempts.")
        }
        
        // MARK: - UPDATE TodoItem
        func updateItem(id: UUID) async throws {
            isLoading = true
            defer { isLoading = false }
            
            if isDirty {
                Task {
                    do {
                        try await updateTodoList()
                    } catch {
                        DDLogError("Failed to update the task list")
                    }
                }
            }
            
            guard let updatedItem = getUpdatedItem(for: id) else { return }
            
            var retryCount = 0
            let maxRetries = 3
            
            updateTodo(todo: updatedItem)

            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.updateTodoItem(updatedItem, revision: revisionValue.getRevision())
                    updateFilteredItems()
                    revisionValue.setRevision(response.revision)
                    isDirty = false
                    DDLogInfo("The task has been successfully updated. Revision: \(response.revision)")
                    return
                } catch let error as ToDoServiceError {
                    switch error {
                    case .badRequest(let message):
                        DDLogError("Bad Request: \(message)")
                        errorMessage = "Bad Request: \(message)"
                    case .unauthorized(let message):
                        DDLogError("Unauthorized: \(message)")
                        errorMessage = "Unauthorized: \(message)"
                    case .notFound(let message):
                        DDLogError("Not Found: \(message)")
                        errorMessage = "Not Found: \(message)"
                    case .serverError(let message):
                        DDLogError("Server Error: \(message)")
                        errorMessage = "Server Error: \(message)"
                    case .unknown(let message):
                        DDLogError("Unknown Error: \(message)")
                        errorMessage = "Unknown Error: \(message)"
                    }
                    retryCount += 1
                    let seconds = 1
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                } catch {
                    DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                    errorMessage = "Unexpected Error: \(error.localizedDescription)"
                    retryCount += 1
                    let seconds = 1
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                }
            }
            
            isDirty = true
            throw ToDoServiceError.unknown("Failed to add task after \(maxRetries) attempts.")
        }
        
        // MARK: - PATCH TodoItem
        func updateTodoList() async throws {
            isLoading = true
            defer { isLoading = false }
                        
            var retryCount = 0
            let maxRetries = 3
            let updatedItems = Array(items.values)
            
            do {
                let response = try await toDoService.updateTodoList(tasks: updatedItems, revision: revisionValue.getRevision())
                DispatchQueue.main.async {
                    for item in response.list {
                        self.items[item.id] = item
                    }
                    self.updateFilteredItems(items: self.items, sortOption: self.currentSortOption)
                    self.completedCount = self.items.values.filter { $0.done }.count
                    self.revisionValue.setRevision(response.revision)
                    self.isDirty = false
                    DDLogInfo("The tasks has been successfully updated. Revision: \(response.revision)")
                }
                return
            } catch let error as ToDoServiceError {
                switch error {
                case .badRequest(let message):
                    DDLogError("Bad Request: \(message)")
                    errorMessage = "Bad Request: \(message)"
                case .unauthorized(let message):
                    DDLogError("Unauthorized: \(message)")
                    errorMessage = "Unauthorized: \(message)"
                case .notFound(let message):
                    DDLogError("Not Found: \(message)")
                    errorMessage = "Not Found: \(message)"
                case .serverError(let message):
                    DDLogError("Server Error: \(message)")
                    errorMessage = "Server Error: \(message)"
                case .unknown(let message):
                    DDLogError("Unknown Error: \(message)")
                    errorMessage = "Unknown Error: \(message)"
                }
                retryCount += 1
                let seconds = 1
                let duration = UInt64(seconds * 1_000_000_000)
                try await Task.sleep(nanoseconds: duration)
            } catch {
                DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                errorMessage = "Unexpected Error: \(error.localizedDescription)"
                retryCount += 1
                let seconds = 1
                let duration = UInt64(seconds * 1_000_000_000)
                try await Task.sleep(nanoseconds: duration)
            }
            
            isDirty = true
            throw ToDoServiceError.unknown("Failed to add task after \(maxRetries) attempts.")
        }

        func getColor(for id: UUID) -> String {
            guard let color = items[id]?.color else {
                return Constants.whiteHex
            }
            return color
        }
        
        func getItem(for id: UUID) -> TodoItem? {
            guard let item = items[id] else { return nil }
            return item
        }
        
        private func getUpdatedItem(for id: UUID) -> TodoItem? {
            guard let todo = items[id] else { return nil }
            let updatedItem = todo.updated(done: !todo.done)
            return updatedItem
        }
                
        func deleteTodo(id: UUID) {
            self.items.removeValue(forKey: id)
            updateFilteredItems()
        }
        
        func addTodo(todo: TodoItem) {
            self.items[todo.id] = todo
            updateFilteredItems()
        }
        
        private func updateTodo(todo: TodoItem) {
            self.items[todo.id] = todo
            updateFilteredItems()
        }
        
        private func updateFilteredItems() {
            self.updateFilteredItems(items: self.items, sortOption: self.currentSortOption)
            self.completedCount = self.items.values.filter { $0.done }.count
        }
        
        func sheetDismiss() async {
            selectedItem = nil
            filtredItems = []
            Task {
                do {
                    try await fetchTasks()
                } catch {
                    print("Error fetching tasks: \(error)")
                }
            }
        }
        
        // MARK: - Filters
        private func updateFilteredItems(items: [UUID: TodoItem], sortOption: SortOption) {
            let sortedItems: [TodoItem]
            
            if showCompleted {
                sortedItems = items.values.sorted {
                    if $0.done == $1.done {
                        switch sortOption {
                        case .byDate:
                            return $0.createdAt > $1.createdAt
                        case .byImportance:
                            return compareImportance($0.importance, $1.importance)
                        case .none:
                            return false
                        }
                    }
                    return $0.done && !$1.done
                }
            } else {
                sortedItems = items.values.filter { !$0.done }.sorted {
                    switch sortOption {
                    case .byDate:
                        return $0.createdAt > $1.createdAt
                    case .byImportance:
                        return compareImportance($0.importance, $1.importance)
                    case .none:
               
                        return false
                    }
                }
            }
            self.filtredItems = sortedItems
        }
        
        private func compareImportance(_ first: Priority, _ second: Priority) -> Bool {
            let order: [Priority: Int] = [.important: 0, .basic: 1, .low: 2]
            return order[first]! < order[second]!
        }
        
        func sortByCreatingDate() {
            self.currentSortOption = .byDate
            updateFilteredItems(items: self.items, sortOption: .byDate)
        }
        
        func sortByImportance() {
            self.currentSortOption = .byImportance
            updateFilteredItems(items: self.items, sortOption: .byImportance)
        }
        
        func showCompletedTasks() {
            self.showCompleted = true
            updateFilteredItems(items: self.items, sortOption: self.currentSortOption)
        }
        
        func hideCompletedTasks() {
            self.showCompleted = false
            updateFilteredItems(items: self.items, sortOption: self.currentSortOption)
        }
    }
}
