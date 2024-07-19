//
//  RevisionValue.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 19.07.2024.
//

import Foundation

@MainActor
class RevisionValue {
    
    static let shared = RevisionValue()
    private init () {}
    
    private var revision: Int = 0
    
    func getRevision() -> Int {
        return self.revision
    }
    
    func setRevision(_ newRevision: Int) {
        self.revision = newRevision
    }
}
