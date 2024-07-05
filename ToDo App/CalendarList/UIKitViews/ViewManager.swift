//
//  ViewManager.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 02.07.2024.
//

import Foundation
import UIKit

final class ViewManager {
    private let dateFormatter = DateConverter()
    static let shared = ViewManager()

    private init() {}

    var items: [TodoItem] = []
    var fileCache = FileCache.shared

    func getCollection(id: String, dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 62, height: 62)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.restorationIdentifier = id
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .backPrimary
        collection.dataSource = dataSource
        collection.delegate = delegate
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.heightAnchor.constraint(equalToConstant: 70).isActive = true

        return collection
    }

    func loadItem(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.fileCache.loadTodoItems(from: Constants.fileName.rawValue)
            self.items = self.fileCache.getTodoItems()
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func groupedSectionsByDate() -> [TableSection] {
        var dateSet: Set<Date> = Set()
        var itemsByDate: [Date: [TodoItem]] = [:]
        var otherItems: [TodoItem] = []

        for item in items {
            if let deadline = item.deadline {
                dateSet.insert(deadline)
                itemsByDate[deadline, default: []].append(item)
            } else {
                otherItems.append(item)
            }
        }

        let sortedDates = Array(dateSet).sorted()

        var dateSections: [(String, [TodoItem])] = []

        for date in sortedDates {
            var items = itemsByDate[date] ?? []
            items.sort { $0.text < $1.text }
            let title = dateFormatter.convertDateToStringDayMonth(date: date) ?? "Другое"
            
            if let index = dateSections.firstIndex(where: { $0.0 == title }) {
                dateSections[index].1.append(contentsOf: items)
            } else {
                dateSections.append((title, items))
            }
        }

        if !otherItems.isEmpty {
            otherItems.sort { $0.text < $1.text }
            if let index = dateSections.firstIndex(where: { $0.0 == "Другое" }) {
                dateSections[index].1.append(contentsOf: otherItems)
            } else {
                dateSections.append(("Другое", otherItems))
            }
        }

        let sections = dateSections.map { TableSection(title: $0.0, todo: $0.1) }

        return sections
    }



    
    func getSortedDates() -> [String] {
        let deadlines = items.compactMap { $0.deadline }
        let hasNilDeadline = items.contains { $0.deadline == nil }
        let sortedDeadlines = deadlines.sorted()
        let dateStrings = sortedDeadlines.compactMap { self.dateFormatter.convertDateToStringDayMonth(date: $0) }
        var seen = Set<String>()
        let uniqueDatesArray = dateStrings.filter { seen.insert($0).inserted }
        var finalUniqueDatesArray = uniqueDatesArray
        if hasNilDeadline {
            finalUniqueDatesArray.append("Другое")
        }
        
        return finalUniqueDatesArray
    }
}
