//
//  ContentView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct TodoItemList: View {
    @FocusState private var isTextFieldFocused: Bool
    @StateObject var viewModel = ViewModel(
        toDoService: ToDoService(
            networkingService: DefaultNetworkingService(token: Constants.token)
        )
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        Section(header: header) {
                            ForEach(Array(viewModel.filtredItems), id: \.id) { item in
                                ToDoItemCell(todoId: item.id, viewModel: viewModel) {
                                    viewModel.selectedItem = item
                                    viewModel.showDetailView.toggle()
                                }
                                .listRowBackground(Color.backSecondary)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        Task {
                                            do {
                                                try await viewModel.updateItem(id: item.id)
                                            } catch {
                                                DDLogError("Error when updating a task")
                                            }
                                        }
                                    } label: {
                                        Label("Check", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        Task {
                                            do {
                                                try await viewModel.deleteItem(id: item.id)
                                            } catch {
                                                DDLogError("Error deleting a task")
                                            }
                                        }
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
                                .focused($isTextFieldFocused)
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
                    Button {
                        viewModel.showCalendarView.toggle()
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.labelPrimary)
                    }
                }
                ToolbarItem {
                    NavigationLink {
                        AddCategoryView()
                    } label: {
                        Image(systemName: "gear.badge.xmark")
                            .foregroundStyle(.labelTertiary)
                    }.disabled(true)
                }
            }
            .navigationTitle("Мои дела")
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background(Color.backPrimary)
        .sheet(isPresented: $viewModel.showDetailView, content: {
            DetailView(todo: viewModel.selectedItem) { todoItem, isDeleted in
                if isDeleted {
                    withAnimation {
                        viewModel.deleteTodo(id: todoItem.id)
                    }
                } else {
                    withAnimation {
                        viewModel.addTodo(todo: todoItem)
                    }
                }
                viewModel.selectedItem = nil
            }
        })
        .fullScreenCover(isPresented: $viewModel.showCalendarView, onDismiss: {
            Task {
                await viewModel.sheetDismiss()
            }
        }, content: {
            CalendarView(isPresented: $viewModel.showCalendarView)
        })
        .onAppear {
            Task {
                do {
                    try await viewModel.fetchTasks()
                } catch {
                    DDLogError("Fetch error")
                }
            }
            DDLogInfo("TodoItemList has appeared")
        }
    }
    
    var header: some View {
        HStack {
            Text("Выполнено - \(viewModel.completedCount)")
                .foregroundStyle(.labelTertiary)
            
            Spacer()
            
            Menu {
                Button(action: viewModel.sortByCreatingDate) {
                    HStack {
                        if viewModel.currentSortOption == .byDate {
                            Image(systemName: "checkmark")
                        }
                        Text("Сортировать по дате создания")
                    }
                }
                Button(action: viewModel.sortByImportance) {
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
    
    private var newItemTextField: some View {
            TextField(
                "",
                text: $viewModel.newItemText,
                prompt: Text("Новое")
            )
            .focused($isTextFieldFocused)
            .foregroundStyle(.labelPrimary)
            .onSubmit {
                isTextFieldFocused = false
                let text = viewModel.newItemText.trimming()
                if text != "" {
                    Task {
                        do {
                            try await viewModel.addItem(text: text)
                        } catch {
                            DDLogError("Error when adding a new task")
                        }
                    }
                }
                viewModel.newItemText = ""
            }
        }
}

#Preview {
    TodoItemList()
}
