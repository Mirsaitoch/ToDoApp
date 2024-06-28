//
//  FileCache.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import Foundation
import SwiftUI

final class FileCache: ObservableObject {
    
    @Published private(set) var toDoItems: [UUID: TodoItem] = [:]
    
    func addTodoItem(_ newTask: TodoItem) {
        toDoItems[newTask.id] = newTask
    }
    
    func deleteTodoItem(_ id: UUID) {
        toDoItems.removeValue(forKey: id)
    }
    
    func saveTodoItems(to fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        let jsonArray = toDoItems.values.map { $0.json }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            try data.write(to: url)
        } catch {
            print("Failed to save: \(error.localizedDescription)")
        }
    }
    
    func updateTodoItem(_ todo: TodoItem, to fileName: String) {
        toDoItems[todo.id] = todo
        saveTodoItems(to: fileName)
    }
    
    func updateTodoItem(id: UUID, text: String? = nil, importance: Priority? = nil, deadline: Date? = nil, isCompleted: Bool? = nil, color: String? = nil, to fileName: String) {
        guard let existingItem = toDoItems[id] else { return }
        let updatedItem = existingItem.updated(
            text: text,
            importance: importance,
            deadline: deadline,
            isCompleted: isCompleted
        )
        toDoItems[id] = updatedItem
        saveTodoItems(to: fileName)
    }
    
    func loadTodoItems(from fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: url)
            
            let decodedData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = decodedData as? [[String: Any]] else { return }
            
            for item in jsonArray {
                if let item = TodoItem.parse(json: item) {
                    addTodoItem(item)
                }
            }
            
        } catch {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

