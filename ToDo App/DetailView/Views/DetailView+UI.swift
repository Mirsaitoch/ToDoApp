//
//  DetailView+UI.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 07.07.2024.
//

import Foundation
import SwiftUI

extension DetailView {

    var importancePicker: some View {
        HStack {
            Text("Важность")
                .foregroundStyle(.labelPrimary)
                .font(.system(size: 17))
            Spacer()
            Picker("Важность", selection: $viewModel.importance) {
                ForEach(Priority.allCases) { priority in
                    switch priority {
                    case .low:
                        Image(systemName: "arrow.down")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.colorGray)
                    case .basic:
                        Text("нет")
                    case .important:
                        Image(systemName: "exclamationmark.2")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.colorRed)
                    }
                }
            }
            .frame(width: 175)
            .pickerStyle(.segmented)
        }
    }
    
    var deadlineToggle: some View {
        Toggle(isOn: $viewModel.isDeadline.animation()) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Сделать до")
                        .foregroundStyle(.labelPrimary)
                }
                
                if viewModel.isDeadline {
                    Text(viewModel.dateDeadlineFormated)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    var calendarPicker: some View {
        DatePicker(
            "Start Date",
            selection: $viewModel.dateDeadline,
            in: Date.now...,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .environment(\.locale, Locale.init(identifier: "ru"))
        
    }
    
    var deleteButton: some View {
        Button(role: .destructive) {
            Task {
                do {
                    try await viewModel.deleteItem()
                }
            }
            completion(todo, true)
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("Удалить")
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .disabled(isNewItem)
    }
}
