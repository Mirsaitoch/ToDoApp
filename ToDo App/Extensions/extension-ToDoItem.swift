//
//  extension-ToDoItem.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import Foundation

extension TodoItem {
    
    var json: Any {
        var data : [String : Any] = [
            "id": id,
            "text": text,
            "isCompleted": isCompleted,
            "createDate": createDate.timeIntervalSince1970
        ]
        
        if importance != .usual {
            data["importance"] = importance.rawValue
        }
        
        if let deadline = deadline {
            data["deadline"] = deadline.timeIntervalSince1970
        }
        
        if let changeDate = changeDate {
            data["changeDate"] = changeDate.timeIntervalSince1970
        }
        
        return data
    }
    
    static func parse(json: Any) -> TodoItem? {
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let id = json["id"] as? String,
              let text = json["text"] as? String,
              let isCompleted = json["isCompleted"] as? Bool,
              let createDateInterval = json["createDate"] as? TimeInterval else {
            return nil
        }
        
        let createDate = Date(timeIntervalSince1970: createDateInterval)
        
        let importanceRawValue = json["importance"] as? String
        let importance = Priority(rawValue: importanceRawValue ?? "usual") ?? .usual
        
        
        var deadline: Date? = nil
        if let deadlineTimeInterval = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        var changeDate: Date? = nil
        if let changeDateTimeInterval = json["changeDate"] as? TimeInterval {
            changeDate = Date(timeIntervalSince1970: changeDateTimeInterval)
        }
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isCompleted: isCompleted, createDate: createDate, changeDate: changeDate)
    }
    
    static func parseCSV(csv: String) -> [TodoItem] {
        var toDoItems = [TodoItem]()
        
        let data = csv
        let rows = data.split(separator: "\n")
                
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
        let changeDateString = changeDate?.description ?? ""
        
        
        let escapedText = text.contains(",") ? "\"\(text)\"" : text // заключаем текстовое поле в кавычки, если оно содержит запятые
        
        return "\(id),\(escapedText),\(importance.rawValue),\(deadlineString),\(isCompleted),\(createDate.description),\(changeDateString)"
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
                
        guard components.count >= 5 else {
            return nil
        }
                
        let id = components[0]
        let text = components[1]
        let importance = Priority(rawValue: components[2]) ?? .usual
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss ZZZ"
        
        let deadline = components[3].isEmpty ? nil : dateFormatter.date(from: components[3])
        let isCompleted = components[4] == "true"
        let createDate = dateFormatter.date(from: components[5]) ?? .now
        let changeDate = components.count > 6 ? (components[6].isEmpty ? nil : dateFormatter.date(from: components[6])) : nil
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isCompleted: isCompleted, createDate: createDate, changeDate: changeDate)
    }
}

