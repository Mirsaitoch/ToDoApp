//
//  PlusButton.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import SwiftUI

struct PlusButton: View {
    var body: some View {
        VStack {
            Spacer()
            Circle()
                .frame(width: 50, height: 50)
                .foregroundStyle(.colorBlue)
                .overlay {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .bold()
                }
                .shadow(color: .colorBlue, radius: 10)
        }
    }
}

#Preview {
    PlusButton()
}
