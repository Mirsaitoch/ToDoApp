//
//  TodoItemListViewModel.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//

import Foundation
import SwiftUI
import Combine

extension TodoItemList {
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var filteredItems: [TodoItem] = []
        @Published var selectedItem: TodoItem?
        @Published var showDetailView = false
        @Published var currentSortOption: SortOption = .byDate
        @Published var newItemText = ""
        
        var fileCache = FileCache.shared
        var completedCount = 0
        private var cancellables: Set<AnyCancellable> = []
        var showCompleted = true
        var firstInit = true
        
        func setup() {
            self.setupSubscriptions()
        }
        
        private func setupSubscriptions() {
            fileCache.$toDoItems
                .sink { [weak self] items in
                    self?.filteredItems = Array(items.values)
                    self?.updateFilteredItems(items: items, sortOption: self?.currentSortOption ?? .byDate)
                    self?.completedCount = items.values.filter { $0.isCompleted }.count
                }
                .store(in: &cancellables)
        }
        
        func deleteItem(id: UUID) {
            fileCache.deleteTodoItem(id)
            fileCache.saveTodoItems()
        }
        
        func compliteItem(item: TodoItem) {
            let newItem = item.updated(isCompleted: !item.isCompleted)
            fileCache.updateTodoItem(updatedItem: newItem)
        }
        
        func loadItems() {
            self.fileCache.loadTodoItems(from: Constants.fileName)
            if self.firstInit {
                self.firstInit.toggle()
                self.sortedByCreatingDate()
                self.hideCompletedTasks()
            }
        }
        
        func getItem(by id: UUID) -> TodoItem? {
            return fileCache.toDoItems[id]
        }
        
        func addItem(_ item: TodoItem) {
            fileCache.addTodoItemAndSave(item: item)
        }
        
        func sheetDismiss() {
            selectedItem = nil
            loadItems()
        }

// MARK: - Filters
        private func updateFilteredItems(items: [UUID: TodoItem], sortOption: SortOption) {
            if showCompleted {
                self.filteredItems = items.values.sorted {
                    if $0.isCompleted == $1.isCompleted {
                        switch sortOption {
                        case .byDate:
                            return $0.createDate > $1.createDate
                        case .byImportance:
                            return compareImportance($0.importance, $1.importance)
                        case .none:
                            return false
                        }
                    }
                    return $0.isCompleted && !$1.isCompleted
                }
            } else {
                self.filteredItems = items.values.filter { !$0.isCompleted }.sorted {
                    switch sortOption {
                    case .byDate:
                        return $0.createDate > $1.createDate
                    case .byImportance:
                        return compareImportance($0.importance, $1.importance)
                    case .none:
                        return false
                    }
                }
            }
        }
        
        func sortedByCreatingDate() {
            self.currentSortOption = .byDate
            self.filteredItems.sort {
                if $0.isCompleted == $1.isCompleted {
                    return $0.createDate > $1.createDate
                }
                return $0.isCompleted && !$1.isCompleted
            }
        }
        
        func sortedByImportance() {
            self.currentSortOption = .byImportance
            self.filteredItems.sort {
                if $0.isCompleted == $1.isCompleted {
                    return compareImportance($0.importance, $1.importance)
                }
                return !$0.isCompleted && $1.isCompleted
            }
        }
        
        private func compareImportance(_ first: Priority, _ second: Priority) -> Bool {
            let order: [Priority: Int] = [.important: 0, .usual: 1, .unimportant: 2]
            return order[first]! < order[second]!
        }
        
        func showCompletedTasks() {
            self.showCompleted = true
            self.filteredItems = fileCache.toDoItems.values.sorted {
                if $0.isCompleted == $1.isCompleted {
                    return $0.createDate > $1.createDate
                }
                return $0.isCompleted && !$1.isCompleted
            }
            
        }
        
        func hideCompletedTasks() {
            self.showCompleted = false
            self.filteredItems = fileCache.toDoItems.values.filter { !$0.isCompleted }.sorted(by: { $0.createDate > $1.createDate })
        }
    }
}
