//
//  CompliteCircle.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 27.06.2024.
//

import SwiftUI

struct CompleteCircle: View {
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(.green)

    }
}

#Preview {
    CompleteCircle()
}
