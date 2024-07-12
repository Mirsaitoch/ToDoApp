//
//  FileCache.swift
//  ToDo Appb
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import FileCachePackage
import SwiftUI

@MainActor
final class FileCache: FileCachePackage.FileCache<TodoItem> {
    
    static let shared = FileCache()
    
    private override init() {
        super.init()
    }
}
