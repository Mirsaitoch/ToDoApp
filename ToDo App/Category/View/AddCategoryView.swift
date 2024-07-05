//
//  AddCategoryView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 05.07.2024.
//

import Foundation
import SwiftUI

struct AddCategoryView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var categoryName: String = ""
    @State private var selectedColor: Color = .black
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Название категории")) {
                    TextField("Введите название", text: $categoryName)
                }
                .listRowBackground(Color.backSecondary)

                
                Section(header: Text("Цвет категории")) {
                    ColorPicker("Выберите цвет", selection: $selectedColor)
                }
                .listRowBackground(Color.backSecondary)
            }
            .scrollContentBackground(.hidden)
            .transition(.slide)
        }
        .background(.backPrimary)
        .navigationTitle("Новая категория")
        .navigationBarItems(trailing: Button("Сохранить") {
            let newCategory = CustomCategory(name: categoryName, color: selectedColor)
            viewModel.customCategories.append(newCategory)
            viewModel.loadCategories()
            dismiss()
        }
        )
    }
}


#Preview {
    AddCategoryView()
}
