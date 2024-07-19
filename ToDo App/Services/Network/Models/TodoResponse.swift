//
//  TodoResponse.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 18.07.2024.
//

import Foundation

struct TodoResponse: Codable {
    let status: String
    let element: TodoItem
    let revision: Int
}
