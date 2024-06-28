//
//  TodoItem.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import Foundation

struct TodoItem: Identifiable, Equatable {
    let id: UUID
    let text: String
    let importance: Priority
    let deadline: Date?
    let isCompleted: Bool
    let createDate: Date
    let changeDate: Date?
    var color: String?
    
    init(id: UUID = UUID(), text: String, importance: Priority, deadline: Date? = nil, isCompleted: Bool, createDate: Date = Date(), changeDate: Date? = nil, color: String = Constants.whiteHes.rawValue) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.createDate = createDate
        self.changeDate = changeDate
        self.color = color
    }
    
    static var testItem = TodoItem(text: "Купить сыр", importance: .unimportant, isCompleted: false)
}

enum Priority: String, CaseIterable, Identifiable {
    case unimportant
    case usual
    case important
    
    var id: Self { self }
}

extension TodoItem {
    func updated(text: String? = nil, importance: Priority? = nil, deadline: Date? = nil, isCompleted: Bool? = nil, changeDate: Date = Date(), color: String? = nil) -> TodoItem {
        return TodoItem(
            id: self.id,
            text: text ?? self.text,
            importance: importance ?? self.importance,
            deadline: deadline ?? self.deadline,
            isCompleted: isCompleted ?? self.isCompleted,
            createDate: self.createDate,
            changeDate: changeDate,
            color: color ?? self.color ?? Constants.whiteHes.rawValue
        )
    }
}

