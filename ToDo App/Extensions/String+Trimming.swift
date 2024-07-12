//
//  String+trimming.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 08.07.2024.
//

import Foundation

extension String {
    func trimming() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
