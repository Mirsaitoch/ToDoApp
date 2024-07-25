//
//  TodoItemModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.07.2024.
//

import Foundation
import SwiftData

@Model
class TodoItemModel {

    var uuid: UUID
    var text: String
    var importance: Priority
    var deadline: Date?
    var done: Bool
    var color: String?
    var createdAt: Date
    var changedAt: Date
    var files: [String]?
    
    init(
        uuid: UUID = UUID(),
        text: String,
        importance: Priority = .basic,
        deadline: Date? = nil,
        done: Bool = false,
        color: String? = "#FFFFFF",
        createdAt: Date = Date(),
        changedAt: Date = Date(),
        files: [String]? = nil
    ) {
        self.uuid = uuid
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.color = color
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.files = files
    }
}
