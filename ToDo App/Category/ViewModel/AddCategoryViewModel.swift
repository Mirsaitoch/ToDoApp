//
//  AddCategoryViewModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 05.07.2024.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

extension AddCategoryView {
    class ViewModel: ObservableObject {
        @Published var category: ItemCategory = .standard(.other)
        @Published var allCategories: [ItemCategory] = []
        @Published var customCategories: [CustomCategory] = [] {
            didSet {
                saveCustomCategories()
            }
        }
        
        var fileCache = FileCache.shared
        
        @Published var text = ""
        @Published var showColorPicker = false
        @Published var selectedColor: Color = .white
        
        init() {
            loadCategories()
            customCategories = loadCustomCategories()
        }

        func loadCategories() {
            let customCategories = loadCustomCategories()
            let standardCategories = DefaultCategory.allCases.map { ItemCategory.standard($0) }
            allCategories = standardCategories + customCategories.map { ItemCategory.custom($0) }
        }
        
        private func loadCustomCategories() -> [CustomCategory] {
            if let savedCategories = UserDefaults.standard.data(forKey: "customCategories"),
               let decodedCategories = try? JSONDecoder().decode([CustomCategory].self, from: savedCategories) {
                return decodedCategories
            }
            return []
        }
        
        private func saveCustomCategories() {
            if let encoded = try? JSONEncoder().encode(customCategories) {
                UserDefaults.standard.set(encoded, forKey: "customCategories")
            }
        }
    }
}
