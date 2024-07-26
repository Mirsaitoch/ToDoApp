import Foundation
import SwiftUI

struct TodoItem: Identifiable, Equatable, Codable {

    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        lhs.id == rhs.id
    }

    let id: UUID
    let text: String
    let importance: Priority
    let deadline: Date?
    let done: Bool
    let color: String?
    let createdAt: Date
    let changedAt: Date
    let lastUpdatedBy: String
    let files: [String]?

    init(
        id: UUID = UUID(),
        text: String,
        importance: Priority = .basic,
        deadline: Date? = nil,
        done: Bool = false,
        color: String? = "#FFFFFF",
        createdAt: Date = Date(),
        changedAt: Date = Date(),
        lastUpdatedBy: String = TodoItem.defaultLastUpdatedBy(),
        files: [String]? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.done = done
        self.color = color
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.lastUpdatedBy = lastUpdatedBy
        self.files = files
    }
    
    @MainActor
    static let testItem = TodoItem(
        text: "Купить сыр"
    )
    
    static func defaultLastUpdatedBy() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
}

enum Priority: String, CaseIterable, Identifiable, Codable, Comparable {
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.order < rhs.order
    }
    
    case low
    case basic
    case important
    
    var id: Self { self }
    
    private var order: Int {
        switch self {
        case .low:
            return 0
        case .basic:
            return 1
        case .important:
            return 2
        }
    }
}

extension TodoItem {
    func updated(
        text: String? = nil,
        importance: Priority? = nil,
        deadline: Date? = nil,
        done: Bool? = nil,
        changedAt: Date = Date(),
        color: String? = nil,
        files: [String]? = nil
    ) -> TodoItem {
        return TodoItem(
            id: self.id,
            text: text ?? self.text,
            importance: importance ?? self.importance,
            deadline: deadline ?? self.deadline,
            done: done ?? self.done,
            color: color ?? self.color,
            createdAt: self.createdAt,
            changedAt: changedAt,
            lastUpdatedBy: self.lastUpdatedBy,
            files: files ?? self.files
        )
    }
}
