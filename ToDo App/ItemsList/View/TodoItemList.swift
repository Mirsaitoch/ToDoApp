//
//  ContentView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct TodoItemList: View {
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
                                        viewModel.compliteItem(item: item)
                                        
                                    } label: {
                                        Label("Check", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
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
                            newItemTextField
                        }
                        .textCase(nil)
                    }
                    .background(Color.backPrimary)
                }
                .background(Color.backPrimary)
                
                PlusButton()
                    .onTapGesture { viewModel.showDetailView.toggle() }
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        CalendarView()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.labelPrimary)
                    }
                }
                ToolbarItem {
                    NavigationLink {
                        AddCategoryView()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(.labelPrimary)
                    }
                }
            }
            .navigationTitle("Мои дела")
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background(Color.backPrimary)
        .sheet(isPresented: $viewModel.showDetailView, onDismiss: viewModel.sheetDismiss) {
            DetailView(itemID: viewModel.selectedItem?.id ?? UUID())
        }
        .onAppear {
            self.viewModel.setup()
            viewModel.loadItems()
            DDLogInfo("TodoItemList has appeared")
        }
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
                Button(action: viewModel.showCompleted ? viewModel.hideCompletedTasks : viewModel.showCompletedTasks) {
                    HStack {
                        Image(systemName: viewModel.showCompleted ? "eye.slash.circle.fill" : "eye.circle.fill")
                        Text(viewModel.showCompleted ? "Скрыть выполненные" : "Показать выполненные")
                    }
                }
            } label: {
                Label("Фильтр", systemImage: "line.horizontal.3.decrease.circle")
                    .labelStyle(.titleAndIcon)
                    .foregroundColor(.labelPrimary)
            }
        }
    }
    
    var newItemTextField: some View {
        TextField("", text: $viewModel.newItemText, prompt: Text("Новое"))
            .onSubmit {
                if viewModel.newItemText.trimming() == "" {
                    viewModel.newItemText = ""
                } else {
                    viewModel.addItem(TodoItem(text: viewModel.newItemText.trimming()))
                    viewModel.newItemText = ""
                }
            }
    }
}

#Preview {
    TodoItemList()
}
