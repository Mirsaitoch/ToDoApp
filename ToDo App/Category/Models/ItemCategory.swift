//
//  Category.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 05.07.2024.
//

import Foundation
import SwiftUI

enum ItemCategory: Identifiable, Hashable {
    case standard(DefaultCategory)
    case custom(CustomCategory)
    
    var id: UUID {
        switch self {
        case .standard(let category):
            return UUID(uuidString: category.rawValue) ?? UUID()
        case .custom(let customCategory):
            return customCategory.id
        }
    }
    
    var name: String {
        switch self {
        case .standard(let category):
            switch category {
            case .work:
                return "Работа"
            case .study:
                return "Учеба"
            case .hobby:
                return "Хобби"
            case .other:
                return "Другое"
            }
        case .custom(let customCategory):
            return customCategory.name
        }
    }
    
    var color: Color {
        switch self {
        case .standard(let category):
            switch category {
            case .work:
                return .red
            case .study:
                return .blue
            case .hobby:
                return .green
            case .other:
                return .gray
            }
        case .custom(let customCategory):
            return customCategory.color
        }
    }
    
    init?(rawValue: String) {
        if let standardCategory = DefaultCategory(rawValue: rawValue) {
            self = .standard(standardCategory)
        } else {
            if let savedCategories = UserDefaults.standard.data(forKey: "customCategories"),
               let customCategories = try? JSONDecoder().decode([CustomCategory].self, from: savedCategories),
               let customCategory = customCategories.first(where: { $0.id.uuidString == rawValue }) {
                self = .custom(customCategory)
            } else {
                return nil
            }
        }
    }
}
