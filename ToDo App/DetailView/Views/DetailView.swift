//
//  DetailView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//

import SwiftUI

struct DetailView: View {
    @State var itemID: UUID
    @StateObject var viewModel: ViewModel
    @FocusState var isFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    init(itemID: UUID) {
        self.itemID = itemID
        self._viewModel = StateObject(wrappedValue: ViewModel(id: itemID))
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
                                viewModel.save()
                                dismiss()
                            }.disabled(viewModel.text.isEmpty)
                        }
                    }
                    .onAppear {
                        self.viewModel.setup()
                        if let colorHex = viewModel.item?.color {
                            viewModel.selectedColor = Color(hex: colorHex)
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
                                viewModel.save()
                                dismiss()
                            }.disabled(viewModel.text.isEmpty)
                        }
                    }
                    .onAppear {
                        self.viewModel.setup()
                        if let colorHex = viewModel.item?.color {
                            viewModel.selectedColor = Color(hex: colorHex)
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
                    categoriesPicker
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
                        categoriesPicker
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
    DetailView(itemID: UUID())
}
