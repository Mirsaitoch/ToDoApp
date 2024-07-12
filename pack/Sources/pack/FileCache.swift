// The Swift Programming Language
// https://docs.swift.org/swift-book

import CocoaLumberjackSwift
import Foundation
import SwiftUI

public protocol CachableJson {
    var json: Any { get }
    static func parse(json: Any) -> Self?
}

public protocol CachableCsv {
    static func parse(csv: String) -> [Self]
    func toCSV() -> String
    static func fromCSV(_ csvString: String) -> Self?
}

public typealias FileCachable = Identifiable & CachableJson & CachableCsv

@MainActor
open class FileCache<T: FileCachable>: ObservableObject {
    
    @Published public private(set) var toDoItems: [UUID: T] = [:]
    
    public init() { }

    public func addTodoItem(_ newTask: T) {
        guard let id = newTask.id as? UUID else { return }
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

    public func addTodoItemAndSave(item: T) {
        addTodoItem(item)
        saveTodoItems()
    }

    public func updateTodoItem(updatedItem: T) {
        guard let id = updatedItem.id as? UUID else { return }
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

            var newItems: [UUID: T] = [:]
            for item in jsonArray {
                if let item = T.parse(json: item) {
                    guard let id = item.id as? UUID else { return }
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

    public func getTodoItems() -> [T] {
        return Array(toDoItems.values)
    }

    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
