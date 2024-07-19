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
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backPrimary.ignoresSafeArea()
                UIKitCalendarView(needsUpdate: $needsUpdate)
                PlusButton()
                    .onTapGesture {
                        showDetailView.toggle()
                    }
            }
            .navigationTitle("Мои дела")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "arrow.backward")
                            .font(.title)
                            .foregroundStyle(.black)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDetailView, content: {
                DetailView(todo: nil) { _, _  in 
                    needsUpdate = true
                }
            })
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
            Task {
                do {
                    await uiViewController.updatePage()
                }
            }
            needsUpdate = false
        }
    }
}

#Preview {
    CalendarView(isPresented: .constant(true))
}
