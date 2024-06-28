//
//  DefaultCircle.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import SwiftUI

struct DefaultCircle: View {
    var body: some View {
        Image(systemName: "circle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(.colorGrayLight)
    }
}

#Preview {
    DefaultCircle()
}
