//
//  FileCache.swift
//  ToDo Appb
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import CocoaLumberjackSwift
import SwiftUI
import SwiftData

@MainActor
final class FileCache: ObservableObject {

    var container: ModelContainer?
    
    init() {
        do {
            container = try ModelContainer(for: TodoItemModel.self)
        } catch {
            container = nil
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    @Published private(set) var toDoItems: [UUID: TodoItem] = [:]

    // MARK: - SwiftData
    
    func insert(_ todoItem: TodoItemModel) {
        container?.mainContext.insert(todoItem)
        DDLogInfo("The object with id: \(todoItem.uuid) has been inserted into the database")
    }
    
    func fetch(predicate: Predicate<TodoItemModel>? = nil, sortOption: SortOption = .none, showCompleted: Bool = true) -> [TodoItemModel] {
        var finalPredicate: Predicate<TodoItemModel>?
        
        if showCompleted {
            finalPredicate = predicate
        } else {
            finalPredicate = #Predicate<TodoItemModel> { !$0.done }
        }
                
//        let sortDescriptor: SortDescriptor<TodoItemModel>
//        switch sortOption {
//        case .byDate:
//            sortDescriptor = SortDescriptor(\.createdAt)
//        case .byImportance:
//            sortDescriptor = SortDescriptor(\.createdAt)
//        case .none:
//            sortDescriptor = SortDescriptor(\.createdAt)
//        }
        var fetchRequest = FetchDescriptor<TodoItemModel>()
        fetchRequest.predicate = finalPredicate
//        fetchRequest.sortBy = [sortDescriptor]
        
        do {
            let items = try container?.mainContext.fetch(fetchRequest)
            DDLogInfo("Fetched \(items?.count ?? 0) items from the database")
            return items ?? []
        } catch {
            DDLogError("Failed to fetch: \(error.localizedDescription)")
            return []
        }
    }

    func delete(_ todoItem: TodoItemModel) {
        container?.mainContext.delete(todoItem)
        DDLogInfo("The object with id: \(todoItem.uuid) has been deleted from the database")
    }
  
    func update(_ todoItem: TodoItemModel) {
            guard let container = container else {
                DDLogError("ModelContainer is not initialized")
                return
            }
            
            var fetchRequest = FetchDescriptor<TodoItemModel>()
            let todoItemId = todoItem.uuid
            fetchRequest.predicate = #Predicate<TodoItemModel> { $0.uuid == todoItemId }

            do {
                let fetchedItems = try container.mainContext.fetch(fetchRequest)
                
                if let existingItem = fetchedItems.first {
                    existingItem.text = todoItem.text
                    existingItem.importance = todoItem.importance
                    existingItem.deadline = todoItem.deadline
                    existingItem.done = todoItem.done
                    existingItem.color = todoItem.color
                    existingItem.changedAt = Date()
                    existingItem.files = todoItem.files
                    
                    
                    DDLogInfo("The object with id: \(todoItem.id) has been updated in the database")
                } else {
                    DDLogError("Failed to update: No item found with id \(todoItem.id)")
                }
            } catch {
                DDLogError("Failed to update: \(error.localizedDescription)")
            }
        }

    // MARK: - JSON
    
    public func addTodoItem(_ newTask: TodoItem) {
        let id = newTask.id
        self.toDoItems[id] = newTask
        DDLogInfo("The object with id: \(newTask.id) has been added")
    }

    public func deleteTodoItem(_ id: UUID) {
        self.toDoItems.removeValue(forKey: id)
        DDLogInfo("The object with id: \(id)  has been deleted")
    }

    public func saveTodoItems(to fileName: String = "Items.json") {
        let url = self.getDocumentsDirectory().appendingPathComponent(fileName)
        let jsonArray = toDoItems.values.map { $0.json }

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            try data.write(to: url)
            DDLogInfo("The data has been saved to a file: \(fileName)")
        } catch {
            DDLogError("Failed to save: \(error.localizedDescription)")
        }
    }
    
    public func addTodoItemAndSave(item: TodoItem) {
        addTodoItem(item)
        saveTodoItems()
    }

    public func updateTodoItem(updatedItem: TodoItem) {
        let id = updatedItem.id
        DispatchQueue.main.async {
            self.toDoItems[id] = updatedItem
            self.saveTodoItems()
        }
        DDLogInfo("The object with id: \(id)  has been updated")
    }

    public func loadTodoItems(from fileName: String) {
        let url = self.getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = decodedData as? [[String: Any]] else { return }

            var newItems: [UUID: TodoItem] = [:]
            for item in jsonArray {
                if let item = TodoItem.parse(json: item) {
                    let id = item.id
                    newItems[id] = item
                }
            }

            DispatchQueue.main.async {
                self.toDoItems = newItems
                DDLogInfo("The data was loaded from a file: \(fileName)")
            }
        } catch {
            DDLogError("Failed to load: \(error.localizedDescription)")
        }
    }

    public func getTodoItems() -> [TodoItem] {
        return Array(toDoItems.values)
    }

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func removeAll() {
        self.toDoItems = [:]
        saveTodoItems()
    }
    
}
