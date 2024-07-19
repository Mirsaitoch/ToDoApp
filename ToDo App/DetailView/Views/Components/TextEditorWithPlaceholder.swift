//
//  TextEditorWithPromt.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 08.07.2024.
//

import SwiftUI

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    private let emptyText = "Что надо сделать?"
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                VStack {
                    Text(emptyText)
                        .padding(.top, 10)
                        .padding(.leading, 6)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            
            TextEditor(text: $text)
                .autocorrectionDisabled()
                .frame(minHeight: 150, maxHeight: 300)
                .padding(.top, text.isEmpty ? 0 : 0)
                .foregroundStyle(.primary)
        }
    }
}
