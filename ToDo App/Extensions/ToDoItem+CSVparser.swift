//
//  ToDoItem+CSVparser.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import Foundation
import FileCachePackage

extension TodoItem: FileCachePackage.CachableCsv {
    static func parse(csv: String) -> [TodoItem] {
        var toDoItems = [TodoItem]()
        let rows = csv.split(separator: "\n")
        for row in rows {
            let csvRow = String(row)
            if let todoItem = TodoItem.fromCSV(csvRow) {
                toDoItems.append(todoItem)
            }
        }
        return toDoItems
    }
    
    func toCSV() -> String {
        let deadlineString = deadline?.description ?? ""
        let changedAtString = changedAt.description
        let colorString = color ?? "#FFFFFF"
        let filesString = files?.joined(separator: ";") ?? ""
        
        let escapedText = text.contains(",") ? "\"\(text)\"" : text
        
        return "\(id),\(escapedText),\(importance.rawValue),\(deadlineString),\(done),\(createdAt.description),\(changedAtString),\(colorString),\(filesString)"
    }
    
    static func fromCSV(_ csvString: String) -> TodoItem? {
        var components = [String]()
        var currentComponent = ""
        var insideText = false
        
        for char in csvString {
            if char == "\"" {
                insideText.toggle()
            } else if char == "," && !insideText {
                components.append(currentComponent)
                currentComponent = ""
            } else {
                currentComponent.append(char)
            }
        }
        
        components.append(currentComponent)
        
        guard components.count >= 8 else {
            return nil
        }
        
        guard let id = UUID(uuidString: components[0]) else { return nil }
        let text = components[1]
        let importance = Priority(rawValue: components[2]) ?? .basic

        let dateFormatter = ISO8601DateFormatter()

        let deadline = components[3].isEmpty ? nil : dateFormatter.date(from: components[3])
        let done = components[4] == "true"
        guard let createdAt = dateFormatter.date(from: components[5]) else { return nil }
        guard let changedAt = dateFormatter.date(from: components[6]) else { return nil }
        let color = components[7].isEmpty ? "#FFFFFF" : components[7]
        let files = components[8].isEmpty ? nil : components[8].split(separator: ";").map { String($0) }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, color: color, createdAt: createdAt, changedAt: changedAt, lastUpdatedBy: TodoItem.defaultLastUpdatedBy(), files: files)
    }
}
