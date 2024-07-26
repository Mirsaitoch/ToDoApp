//
//  ToDoItemDelailViewModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//

import CocoaLumberjackSwift
import Foundation
import SwiftUI

extension DetailView {
    @MainActor
    final class ViewModel: ObservableObject, @unchecked Sendable {
        
        var revisionValue = RevisionValue.shared
        var todo: TodoItem
        var dateConverter = DateConverter()
        @Published var text = ""
        @Published var importance = Priority.basic
        @Published var done = false
        @Published var isDeadline = false
        @Published var dateDeadline = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        @Published var showColorPicker = false
        @Published var selectedColor: Color = .white
        @Published var currentOrientation = UIDevice.current.orientation
        
        @Published var isLoading: Bool = false
        @Published var errorMessage: String?
        @Published var isDirty: Bool = false
        private let toDoService: ToDoService
        
        init(toDoService: ToDoService, todo: TodoItem) {
            self.todo = todo
            self.toDoService = toDoService
        }
        
        func setup() {
            DispatchQueue.main.async {
                self.text = self.todo.text
                self.importance = self.todo.importance
                self.done = self.todo.done
                if let colorHex = self.todo.color {
                    self.selectedColor = Color(hex: colorHex)
                }
                guard let newDeadline = self.todo.deadline else { return }
                self.dateDeadline = newDeadline
                self.isDeadline = true
            }
        }
        
        // MARK: - DELETE Task
        func deleteItem() async throws {
            isLoading = true
            defer { isLoading = false }
            
            var retryCount = 0
            let maxRetries = 3
            
            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.deleteTodoItem(by: todo.id, revision: revisionValue.getRevision())
                    revisionValue.setRevision(response.revision)
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
                    let seconds = 3
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                } catch {
                    DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                    retryCount += 1
                    let seconds = 3
                    let duration = UInt64(seconds * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                }
            }
            isDirty = true
            throw ToDoServiceError.unknown("Failed to delete task after \(maxRetries) attempts.")
        }
        
        // MARK: - UPDATE Task
        func updateItem() async throws {
            isLoading = true
            defer { isLoading = false }
            
            let updatedItem = getUpdatedItem()
            
            var retryCount = 0
            let maxRetries = 3
            
            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.updateTodoItem(updatedItem, revision: revisionValue.getRevision())
                    revisionValue.setRevision(response.revision)
                    DDLogInfo("The task has been successfully add/updated. Revision: \(response.revision)")
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
                    let delay = pow(2.0, Double(retryCount))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } catch {
                    DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                    errorMessage = "Unexpected Error: \(error.localizedDescription)"
                    retryCount += 1
                    let delay = pow(2.0, Double(retryCount))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
            
            throw ToDoServiceError.unknown("Failed to add/update task after \(maxRetries) attempts.")
        }
        
        // MARK: - ADD Task
        func addItem() async throws {
            isLoading = true
            defer { isLoading = false }
            
            let newItem = getUpdatedItem()
            var retryCount = 0
            let maxRetries = 3
                        
            while retryCount < maxRetries {
                do {
                    let response = try await toDoService.addTodoItem(newItem, revision: revisionValue.getRevision())
                    revisionValue.setRevision(response.revision)
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
                    let delay = pow(2.0, Double(retryCount))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } catch {
                    DDLogError("An unexpected error occurred: \(error.localizedDescription)")
                    errorMessage = "Unexpected Error: \(error.localizedDescription)"
                    retryCount += 1
                    let delay = pow(2.0, Double(retryCount))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        func getUpdatedItem() -> TodoItem {
            let updatedItem = TodoItem(
                id: todo.id,
                text: self.text.trimmed(),
                importance: self.importance,
                deadline: self.isDeadline ? self.dateDeadline : nil,
                done: self.done,
                color: self.selectedColor.hexString
            )
            return updatedItem
        }
        
        var dateDeadlineFormated: String {
            dateConverter.convertDateToStringDayMonthYear(date: dateDeadline)
        }
        
        func toggleShowColorPicker() {
            showColorPicker.toggle()
        }
        
        let orientationHasChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    }
}
