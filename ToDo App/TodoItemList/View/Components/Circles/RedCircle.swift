//
//  RedCircleView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 26.06.2024.
//

import SwiftUI

struct RedCircle: View {
    var body: some View {
        Image(systemName: "circle")
            .resizable()
            .foregroundColor(.red)
            .frame(width: 20, height: 20)
            .overlay(
                Image(systemName: "circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.colorLightRed)
                    .frame(width: 20, height: 20)
            )
    }
}

#Preview {
    RedCircle()
}
