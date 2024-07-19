//
//  DetailView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct DetailView: View {
    @State var todo: TodoItem
    var isNewItem = true
    @StateObject var viewModel: ViewModel
    @FocusState var isFocused: Bool
    @Environment(\.dismiss) var dismiss
    var completion: (TodoItem, Bool) -> Void
    
    init(todo: TodoItem?, completion: @escaping (TodoItem, Bool) -> Void) {
        self.completion = completion
        
        var tempTodo = TodoItem(text: "")
        
        if let todoItem = todo {
            tempTodo = todoItem
            self.isNewItem = false
        }
        
        self._todo = State(initialValue: tempTodo)
        
        let viewModel = ViewModel(
            toDoService: ToDoService(networkingService: DefaultNetworkingService(token: Constants.token)),
            todo: tempTodo
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.currentOrientation == .landscapeLeft || viewModel.currentOrientation == .landscapeRight {
                landscape
                    .background(.backPrimary)
                    .navigationTitle("Дело")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Отменить") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Сохранить") {
                                Task {
                                    do {
                                        if isNewItem {
                                            try await viewModel.addItem()
                                        } else {
                                            try await viewModel.updateItem()
                                        }
                                    }
                                }
                                completion(viewModel.getUpdatedItem(), false)
                                dismiss()
                            }.disabled(viewModel.text.isEmpty)
                        }
                    }
                    .onAppear {
                        if !isNewItem {
                            viewModel.setup()
                        }
                    }
            } else {
                portrait
                    .background(.backPrimary)
                    .navigationTitle("Дело")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Отменить") {
                                dismiss()
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Сохранить") {
                                Task {
                                    do {
                                        if isNewItem {
                                            try await viewModel.addItem()
                                        } else {
                                            try await viewModel.updateItem()
                                        }
                                    }
                                }
                                completion(viewModel.getUpdatedItem(), false)
                                dismiss()
                            }.disabled(viewModel.text.isEmpty)
                        }
                    }
                    .onAppear {
                        if !isNewItem {
                            viewModel.setup()
                        }
                    }
            }
        }
        .onReceive(viewModel.orientationHasChanged) { _ in
            viewModel.currentOrientation = UIDevice.current.orientation
        }
    }
    
    var portrait: some View {
        VStack {
            Form {
                Section {
                    TextEditorWithPlaceholder(text: $viewModel.text)
                }
                .listRowBackground(Color.backSecondary)
                
                Section {
                    importancePicker
                    deadlineToggle
                    if viewModel.isDeadline {
                        calendarPicker
                    }
                }
                .listRowBackground(Color.backSecondary)
                
                Section {
                    Button(action: viewModel.toggleShowColorPicker ) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Цвет")
                                Text(viewModel.selectedColor.hexString)
                                    .bold()
                            }
                            .foregroundStyle(.labelPrimary)
                            
                            Spacer()
                            
                            CustomColorPickerView(colorValue: $viewModel.selectedColor)
                        }
                    }
                }
                .listRowBackground(Color.backSecondary)
                
                Section {
                    deleteButton
                }
                .listRowBackground(Color.backSecondary)
            }
            .scrollContentBackground(.hidden)
            .transition(.slide)
        }
    }
    
    var landscape: some View {
        HStack {
            Form {
                Section {
                    TextEditorWithPlaceholder(text: $viewModel.text)
                        .frame(maxWidth: isFocused ? .infinity : .none, maxHeight: .infinity)
                        .background(Color.backSecondary)
                        .transition(.slide)
                }
                .listRowBackground(Color.backSecondary)
            }
            .scrollContentBackground(.hidden)
            
            if !isFocused {
                Form {
                    Section {
                        importancePicker
                        deadlineToggle
                        if viewModel.isDeadline {
                            calendarPicker
                        }
                    }
                    .listRowBackground(Color.backSecondary)
                    
                    Section {
                        Button {
                            viewModel.showColorPicker.toggle()
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Цвет")
                                    Text(viewModel.selectedColor.hexString)
                                        .bold()
                                }
                                .foregroundStyle(.labelPrimary)
                                
                                Spacer()
                                
                                CustomColorPickerView(colorValue: $viewModel.selectedColor)
                            }
                        }
                    }
                    .listRowBackground(Color.backSecondary)
                    
                    Section {
                        deleteButton
                    }
                    .listRowBackground(Color.backSecondary)
                }
                .frame(maxWidth: .infinity)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    DetailView(todo: nil) { _, _  in 
        print("")
    }
}
