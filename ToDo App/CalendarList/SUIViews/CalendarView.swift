//
//  TodoListUIKitView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 01.07.2024.
//

import SwiftUI

struct CalendarView: View {
    @State var showDetailView = false
    @State var needsUpdate = false
    var body: some View {
        ZStack {
            Color.backPrimary.ignoresSafeArea()
            UIKitCalendarView(needsUpdate: $needsUpdate)
            PlusButton()
                .onTapGesture {
                    showDetailView.toggle()
                }
        }
        .navigationTitle("Мои дела")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDetailView, onDismiss: {
            DispatchQueue.main.async {
                
                needsUpdate = true
            }
        }) {
            ToDoItemDetailView(itemID: UUID())
        }
    }
}

struct UIKitCalendarView: UIViewControllerRepresentable {
    @Binding var needsUpdate: Bool
    func makeUIViewController(context: Context) -> TodoListViewController {
        let viewController = TodoListViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: TodoListViewController, context: Context) {
        if needsUpdate {
            uiViewController.updatePage()
            DispatchQueue.main.async {
                needsUpdate = false
            }
        }
    }
}

#Preview {
    CalendarView()
}
