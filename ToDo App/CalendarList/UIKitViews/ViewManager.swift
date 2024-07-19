//
//  ViewManager.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 02.07.2024.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

@MainActor
final class ViewManager {
    private let dateFormatter = DateConverter()
    static let shared = ViewManager()
    
    var isLoading: Bool = false
    var errorMessage: String?
    var isDirty: Bool = false
    var revisionValue = RevisionValue.shared
    
    private init() {}
    
    var items: [TodoItem] = []
    
    var fileCache = FileCache.shared
    
    func getCollection(id: String, dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 62, height: 62)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.restorationIdentifier = id
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .backPrimary
        collection.dataSource = dataSource
        collection.delegate = delegate
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        return collection
    }
    
    // MARK: - GET TodoItems
    func fetchTasks(toDoService: ToDoService, completion: @escaping () -> Void) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if isDirty {
            Task {
                do {
                    try await updateTodoList(toDoService: toDoService)
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
                    self.items = response.list
                    self.revisionValue.setRevision(response.revision)
                    self.isDirty = false
                    completion()
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
    
    // MARK: - UPDATE TodoItem
    func updateItem(toDoService: ToDoService, updatedItem: TodoItem, completion: @escaping () -> Void) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if isDirty {
            Task {
                do {
                    try await updateTodoList(toDoService: toDoService)
                } catch {
                    DDLogError("Failed to update the task list")
                }
            }
        }
        
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            do {
                let response = try await toDoService.updateTodoItem(updatedItem, revision: revisionValue.getRevision())
                guard let index = items.firstIndex(where: {updatedItem.id == $0.id }) else {
                    DDLogError("There is no element that we are updating")
                    return
                }
                self.items[index] = updatedItem
                revisionValue.setRevision(response.revision)
                isDirty = false
                completion()
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
        
        isDirty = true
        throw ToDoServiceError.unknown("Failed to add task after \(maxRetries) attempts.")
    }
    
    // MARK: - UPDATE TodoItemList
    
    func updateTodoList(toDoService: ToDoService) async throws {
        isLoading = true
        defer { isLoading = false }
        
        var retryCount = 0
        let maxRetries = 3
        let updatedItems = items
        
        do {
            let response = try await toDoService.updateTodoList(tasks: updatedItems, revision: revisionValue.getRevision())
            DispatchQueue.main.async {
                self.items = response.list
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
            DDLogError("An unexpected error occurred: \(error)")
            errorMessage = "Unexpected Error: \(error.localizedDescription)"
            retryCount += 1
            let seconds = 1
            let duration = UInt64(seconds * 1_000_000_000)
            try await Task.sleep(nanoseconds: duration)
        }
        
        isDirty = true
        throw ToDoServiceError.unknown("Failed to add task after \(maxRetries) attempts.")
    }
    
    func groupedSectionsByDate() -> [TableSection] {
        var dateSet: Set<Date> = Set()
        var itemsByDate: [Date: [TodoItem]] = [:]
        var otherItems: [TodoItem] = []
        
        for item in items {
            if let deadline = item.deadline {
                dateSet.insert(deadline)
                itemsByDate[deadline, default: []].append(item)
            } else {
                otherItems.append(item)
            }
        }
        
        let sortedDates = Array(dateSet).sorted()
        
        var dateSections: [(String, [TodoItem])] = []
        
        for date in sortedDates {
            var items = itemsByDate[date] ?? []
            items.sort { $0.text < $1.text }
            let title = dateFormatter.convertDateToStringDayMonth(date: date) ?? "Другое"
            
            if let index = dateSections.firstIndex(where: { $0.0 == title }) {
                dateSections[index].1.append(contentsOf: items)
            } else {
                dateSections.append((title, items))
            }
        }
        
        if !otherItems.isEmpty {
            otherItems.sort { $0.text < $1.text }
            if let index = dateSections.firstIndex(where: { $0.0 == "Другое" }) {
                dateSections[index].1.append(contentsOf: otherItems)
            } else {
                dateSections.append(("Другое", otherItems))
            }
        }
        
        let sections = dateSections.map { TableSection(title: $0.0, todo: $0.1) }
        
        return sections
    }
    
    func getSortedDates() -> [String] {
        let deadlines = items.compactMap { $0.deadline }
        let hasNilDeadline = items.contains { $0.deadline == nil }
        let sortedDeadlines = deadlines.sorted()
        let dateStrings = sortedDeadlines.compactMap { self.dateFormatter.convertDateToStringDayMonth(date: $0) }
        var seen = Set<String>()
        let uniqueDatesArray = dateStrings.filter { seen.insert($0).inserted }
        var finalUniqueDatesArray = uniqueDatesArray
        if hasNilDeadline {
            finalUniqueDatesArray.append("Другое")
        }
        
        return finalUniqueDatesArray
    }
}
