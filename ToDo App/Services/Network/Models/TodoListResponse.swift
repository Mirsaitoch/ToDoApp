//
//  TodoListResponse.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 18.07.2024.
//

import Foundation

struct TodoListResponse: Codable {
    let status: String
    let list: [TodoItem]
    let revision: Int
}
