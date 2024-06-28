//
//  ContentView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import SwiftUI

struct TodoItemList: View {
    @StateObject private var fileCache = FileCache()
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        Section(header: header) {
                            ForEach(Array(viewModel.filteredItems), id: \.id) { item in
                                ToDoItemCell(todoId: item.id) {
                                    viewModel.selectedItem = item
                                    viewModel.showDetailView.toggle()
                                }
                                .listRowBackground(Color.backSecondary)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        viewModel.triggerFeedback()
                                        viewModel.compliteItem(item: item)
                                        
                                    } label: {
                                        Label("Check", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        viewModel.triggerFeedback()
                                        viewModel.deleteItem(id: item.id)
                                        
                                    } label: {
                                        Label("Trash", systemImage: "trash.fill")
                                    }
                                    .tint(.red)
                                    
                                    Button {
                                        viewModel.selectedItem = item
                                        viewModel.showDetailView.toggle()
                                    } label: {
                                        Label("Info", systemImage: "info.circle.fill")
                                    }
                                    .tint(.gray)
                                }
                            }
                        }
                        .textCase(nil)
                    }
                    .background(Color.backPrimary)
                }
                .background(Color.backPrimary)
                
                PlusButton()
                    .onTapGesture {
                        viewModel.showDetailView.toggle()
                    }
            }
            .navigationTitle("Мои дела")
        }
        .scrollContentBackground(.hidden)
        .background(Color.backPrimary)
        .sheet(isPresented: $viewModel.showDetailView, onDismiss: {
            viewModel.selectedItem = nil
            DispatchQueue.global(qos: .background).async {
                viewModel.loadItems()
            }
        }) {
            ToDoItemDetailView(itemID: viewModel.selectedItem?.id ?? UUID())
                .environmentObject(fileCache)
        }
        .onAppear {
            self.viewModel.setup(self.fileCache)
            
            DispatchQueue.global(qos: .background).async {
                viewModel.loadItems()
            }
        }
        .environmentObject(fileCache)
    }
    
    var header: some View {
        HStack {
            Text("Выполнено - \(viewModel.completedCount)")
                .foregroundStyle(.labelTertiary)
            
            Spacer()
            
            Menu {
                Button(action: viewModel.sortedByCreatingDate) {
                    HStack {
                        if viewModel.currentSortOption == .byDate {
                            Image(systemName: "checkmark")
                        }
                        Text("Сортировать по дате создания")
                    }
                }
                Button(action: viewModel.sortedByImportance) {
                    HStack {
                        if viewModel.currentSortOption == .byImportance {
                            Image(systemName: "checkmark")
                        }
                        Text("Сортировать по важности")
                    }
                }
                Button(action: {
                    viewModel.showCompleted ? viewModel.hideCompletedTasks() : viewModel.showCompletedTasks()
                }) {
                    Text(viewModel.showCompleted ? "Скрыть выполненные" : "Показать выполненные")
                }
            } label: {
                Label("Фильтр", systemImage: "line.horizontal.3.decrease.circle")
                    .labelStyle(.titleAndIcon)
            }
        }
    }
}

#Preview {
    TodoItemList()
}
