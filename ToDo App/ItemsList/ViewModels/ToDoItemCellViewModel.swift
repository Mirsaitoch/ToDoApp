//
//  ToDoItemCellViewModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 12.07.2024.
//

import Foundation

extension ToDoItemCell {
    @MainActor
    class ViewModel: ObservableObject {
        let fileCache = FileCache.shared
        
        func getColor(for id: UUID) -> String {
            fileCache.toDoItems[id]?.color ?? "#FFFFFF"
        }
        
        func getItem(for id: UUID) -> TodoItem? {
            fileCache.toDoItems[id]
        }
        
        func updateItem(for id: UUID) {
            guard let todo = getItem(for: id) else { return }
            let updatedItem = todo.updated(isCompleted: !todo.isCompleted)
            fileCache.updateTodoItem(updatedItem: updatedItem)
        }
    }
}
