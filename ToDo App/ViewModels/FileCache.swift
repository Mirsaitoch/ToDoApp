//
//  FileCache.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import Foundation


final class FileCache {
    private(set) var toDoItems = [TodoItem]()
    
    func addTodoItem(_ newTask: TodoItem) {
        if !toDoItems.contains(where: { $0.id == newTask.id }) { //защита от дублирования задач
            toDoItems.append(newTask)
        }
    }
    
    func deleteTodoItem(_ id: String) {
        toDoItems.removeAll { $0.id == id }
    }
    
    func saveTodoItems(to fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        let jsonArray = toDoItems.map { $0.json }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            try data.write(to: url)
        } catch {
            print("Failed to save: \(error.localizedDescription)")
        }
    }
    
    func loadTodoItems(from fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: url)
            
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                toDoItems = jsonArray.compactMap { TodoItem.parse(json: $0) }
            }
            
        } catch {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
