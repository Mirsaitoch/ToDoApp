//
//  ToDoItemCell.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct ToDoItemCell: View {
    @State var todoId: UUID
    @ObservedObject var viewModel: TodoItemList.ViewModel
    var action: () -> Void
    private let dateConverter = DateConverter()
    
    var body: some View {
        HStack {
            smallCircle
            VStack(alignment: .leading) {
                textTask
                calendar
            }
            .padding(.leading, 5)
            Spacer()
            colorRectangle
            Image(systemName: "chevron.right")
                .foregroundStyle(.colorGray)
            
        }
        .onTapGesture {
            action()
        }
    }
    
    var colorRectangle: some View {
        Rectangle()
            .fill(Color(hex: viewModel.getColor(for: todoId)))
            .frame(width: 5)
            .overlay(Rectangle().stroke(Color.labelPrimary, style: StrokeStyle(lineWidth: 1)))
    }
    
    var textTask: some View {
        HStack {
            if let todo = viewModel.getItem(for: todoId) {
                if !todo.done && todo.importance != .basic {
                    Text(todo.importance == .important ? Image(systemName: "exclamationmark.2") : Image(systemName: "arrow.down"))
                        .foregroundStyle(todo.importance == .important ? .colorRed : .colorGray)
                        .opacity(todo.done ? 0 : 1)
                        .animation(.easeInOut(duration: 2), value: todo.done)
                }
                
                Text("\(todo.text)")
                    .lineLimit(3)
                    .strikethrough(todo.done, color: .labelTertiary)
                    .foregroundStyle(todo.done ? .labelTertiary : .labelPrimary)
                    .animation(.default, value: todo.done)
                
            }
        }
        .transition(.opacity)
        .font(.system(size: 17))
    }
    
    var calendar: some View {
        HStack {
            if let todo = viewModel.getItem(for: todoId) {
                if let deadline = dateConverter.convertDateToStringDayMonth(date: todo.deadline) {
                    Text(Image(systemName: "calendar"))
                    
                    Text(deadline)
                }
            }
        }
        .font(.system(size: 15))
        .foregroundStyle(.labelTertiary)
    }
    
    var smallCircle: some View {
        VStack {
            if let todo = viewModel.getItem(for: todoId) {
                VStack {
                    if todo.done {
                        CompleteCircle()
                    } else {
                        if todo.importance == .important {
                            RedCircle()
                        } else {
                            DefaultCircle()
                        }
                    }
                }
                .onTapGesture {
                    Task {
                        do {
                            try await viewModel.updateItem(id: todoId)
                        } catch {
                            DDLogError("Error when updating a task")
                        }
                    }
                }
            }
        }
    }
}
