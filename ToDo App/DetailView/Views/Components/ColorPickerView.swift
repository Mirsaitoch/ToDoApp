//
//  ColorPickerView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 28.06.2024.
//

import SwiftUI

struct CustomColorPickerView: View {
    
    @Binding var colorValue: Color
    
    var body: some View {
        colorValue
            .frame(width: 30, height: 30, alignment: .center)
            .cornerRadius(7.0)
            .overlay(RoundedRectangle(cornerRadius: 10.0).stroke(Color.white, style: StrokeStyle(lineWidth: 5)))
            .padding(10)
            .background(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .pink]), center: .center).cornerRadius(20.0))
            .overlay(ColorPicker("", selection: $colorValue).labelsHidden().opacity(0.015))
            .shadow(radius: 5.0)
    }
}
