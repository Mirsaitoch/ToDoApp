//
//  ToDo_AppApp.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 14.06.2024.
//

import CocoaLumberjackSwift
import SwiftUI

@main
struct ToDoApp: App {
    
    init() {
        DDLog.add(DDOSLogger.sharedInstance)
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    var body: some Scene {
        WindowGroup {
            TodoItemList()
        }
    }
}
