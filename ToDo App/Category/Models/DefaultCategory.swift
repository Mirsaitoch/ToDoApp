//
//  DefaultCategory.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 05.07.2024.
//

import Foundation

enum DefaultCategory: String, CaseIterable, Identifiable, Hashable {
    case work
    case study
    case hobby
    case other
    
    var id: Self { self }
}

