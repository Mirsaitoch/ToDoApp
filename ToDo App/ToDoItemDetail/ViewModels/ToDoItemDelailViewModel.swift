//
//  ToDoItemDelailViewModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//



import Foundation
import SwiftUI

extension ToDoItemDetailView {
    class ViewModel: ObservableObject {
        
        var id: UUID
        var fileCache: FileCache?
        var item: TodoItem?
        var dateConverter = DateConverter()
        @Published var text = ""
        @Published var emptyText = "Что надо сделать?"
        @Published var importance = Priority.usual
        @Published var isDeadline = false
        @Published var dateDeadline = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        @Published var showColorPicker = false
        @Published var selectedColor: Color = .white
        
        init(id: UUID = UUID()) {
            self.id = id
        }
        
        var dateDeadlineFormated: String {
            dateConverter.convertDateToStringDayMonthYear(date: dateDeadline)
        }
        
        func setup(_ fileCache: FileCache) {
            self.fileCache = fileCache
            self.item = fileCache.toDoItems[id]
            guard let newItem = item else { return }
            self.text = newItem.text
            self.importance = newItem.importance
            guard let newDeadline = newItem.deadline else { return }
            self.dateDeadline = newDeadline
            self.isDeadline = true
        }
        
        func save() {
            DispatchQueue.main.async {
                let todoItem = TodoItem(
                    id: self.id,
                    text: self.text,
                    importance: self.importance,
                    deadline: self.isDeadline ? self.dateDeadline : nil,
                    isCompleted: false,
                    color: self.selectedColor.hexString
                )
                guard let fileCache = self.fileCache else { return }
                fileCache.addTodoItem(todoItem)
                fileCache.saveTodoItems(to: Constants.fileName.rawValue)
            }
        }
        
        func delete() {
            DispatchQueue.main.async {
                guard let fileCache = self.fileCache else { return }
                guard let item = self.item else { return }
                fileCache.deleteTodoItem(item.id)
                fileCache.saveTodoItems(to: Constants.fileName.rawValue)
            }
        }
        
        
        @Published var currentOrientation = UIDevice.current.orientation
        
        let orientationHasChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    }
}
