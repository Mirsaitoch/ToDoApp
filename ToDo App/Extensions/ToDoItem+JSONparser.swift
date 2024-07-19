//
//  ToDoItem+JSONparser.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import Foundation
import FileCachePackage

extension TodoItem: FileCachePackage.CachableJson {
    var json: Any {
        var data: [String: Any] = [
            "id": id.uuidString,
            "text": text,
            "done": done,
            "createdAt": createdAt.timeIntervalSince1970,
            "changedAt": changedAt.timeIntervalSince1970
        ]
        
        if importance != .basic {
            data["importance"] = importance.rawValue
        }

        if let files = files {
            data["files"] = files
        }
        
        if let deadline = deadline {
            data["deadline"] = deadline.timeIntervalSince1970
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
              let done = json["done"] as? Bool,
              let createdAtInterval = json["createdAt"] as? TimeInterval,
              let changeAtInterval = json["changedAt"] as? TimeInterval else {
            return nil
        }
        
        let createdAt = Date(timeIntervalSince1970: createdAtInterval)
        
        let changedAt = Date(timeIntervalSince1970: changeAtInterval)

        let importanceRawValue = json["importance"] as? String
        let importance = Priority(rawValue: importanceRawValue ?? "usual") ?? .basic
        
        let files = json["files"] as? [String]
        
        var deadline: Date?
        if let deadlineTimeInterval = json["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        let color = json["color"] as? String ?? "#FFFFFF"
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, done: done, color: color, createdAt: createdAt, changedAt: changedAt, lastUpdatedBy: TodoItem.defaultLastUpdatedBy(), files: files)
    }
}
