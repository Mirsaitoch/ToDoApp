//
//  TodoItem.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import Foundation

struct TodoItem: Identifiable {
    var id: String
    var text: String
    var importance: Priority
    var deadline: Date?
    var isCompleted: Bool
    var createDate: Date
    var changeDate: Date?
    
    init(id: String?, text: String, importance: Priority, deadline: Date? = nil, isCompleted: Bool, createDate: Date, changeDate: Date? = nil) {
        if let itemId = id {
            self.id = itemId
        } else {
            self.id = UUID().uuidString
        }
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createDate = createDate
        self.changeDate = changeDate
    }
}


enum Priority: String {
    case unimportant
    case usual
    case important
}

