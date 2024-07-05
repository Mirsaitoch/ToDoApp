//
//  CustomCategory.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 05.07.2024.
//

import Foundation
import SwiftUI

struct CustomCategory: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var colorHex: String
    
    var color: Color {
        Color(hex: colorHex)
    }

    enum CodingKeys: CodingKey {
        case id, name, colorHex
    }

    init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.colorHex = color.hexString
    }
}
