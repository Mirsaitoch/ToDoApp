//
//  ToDoItem+JSONparser.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import Foundation

import Foundation

extension TodoItem {
    var json: Any {
        var data: [String: Any] = [
            "id": id.uuidString,
            "text": text,
            "isCompleted": isCompleted,
            "createDate": createDate.timeIntervalSince1970
        ]
        
        if importance != .usual {
            data["importance"] = importance.rawValue
        }
        
        if case let .standard(standardCategory) = category, standardCategory != .other {
            data["category"] = standardCategory.rawValue
        } else if case let .custom(customCategory) = category {
            data["category"] = customCategory.id.uuidString
        }

        
        if let deadline = deadline {
            data["deadline"] = deadline.timeIntervalSince1970
        }
        
        if let changeDate = changeDate {
            data["changeDate"] = changeDate.timeIntervalSince1970
        }
        
        if let color = color {
            data["color"] = color
        }
        
        return data
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let id = (json["id"] as? String).flatMap({ UUID(uuidString: $0) }),
              let text = json["text"] as? String,
              let isCompleted = json["isCompleted"] as? Bool,
              let createDateInterval = json["createDate"] as? TimeInterval else {
            return nil
        }
        
        let createDate = Date(timeIntervalSince1970: createDateInterval)
        
        let importanceRawValue = json["importance"] as? String
        let importance = Priority(rawValue: importanceRawValue ?? "usual") ?? .usual
        
        let categoryRawValue = json["category"] as? String
        let category = ItemCategory(rawValue: categoryRawValue ?? "other") ?? .standard(.other)
        
        var deadline: Date? = nil
        if let deadlineTimeInterval = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        var changeDate: Date? = nil
        if let changeDateTimeInterval = json["changeDate"] as? TimeInterval {
            changeDate = Date(timeIntervalSince1970: changeDateTimeInterval)
        }
        
        let color = json["color"] as? String ?? "#FFFFFF"
        
        return TodoItem(id: id, text: text, importance: importance, category: category, deadline: deadline, isCompleted: isCompleted, createDate: createDate, changeDate: changeDate, color: color)
    }
}
