//
//  DateConverter.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.06.2024.
//

import Foundation

final class DateConverter {
    
    func convertDateToStringDayMonth(date: Date?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.dateFormat = "d MMMM"
        guard let date = date else { return nil}
        return dateFormatter.string(from: date)
    }
    
    func convertDateToStringDayMonthYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }
}
