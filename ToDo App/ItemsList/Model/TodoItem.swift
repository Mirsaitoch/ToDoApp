import Foundation
import SwiftUI

struct TodoItem: Identifiable, Equatable, Hashable {

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

    static let testItem = TodoItem(
        text: "Купить сыр"
    )

    static func defaultLastUpdatedBy() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
}

enum Priority: String, CaseIterable, Identifiable, Codable {
    case low
    case basic
    case important

    var id: Self { self }
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

extension TodoItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case done
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case color
        case lastUpdatedBy = "last_updated_by"
        case files
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        importance = try container.decode(Priority.self, forKey: .importance)
        if let deadlineTimestamp = try container.decodeIfPresent(Double.self, forKey: .deadline) {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        } else { deadline = nil }
        done = try container.decode(Bool.self, forKey: .done)
        let createdAtTimestamp = try container.decode(Double.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        let changedAtTimestamp = try container.decode(Double.self, forKey: .changedAt)
        changedAt = Date(timeIntervalSince1970: changedAtTimestamp)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        lastUpdatedBy = try container.decode(String.self, forKey: .lastUpdatedBy)
        files = try container.decodeIfPresent([String].self, forKey: .files)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(importance, forKey: .importance)
        deadline == nil ? try container.encodeNil(forKey: .deadline) :
        try container.encodeIfPresent(Int(deadline!.timeIntervalSince1970), forKey: .deadline)
        try container.encode(done, forKey: .done)
        try container.encode(Int(createdAt.timeIntervalSince1970), forKey: .createdAt)
        try container.encode(Int(changedAt.timeIntervalSince1970), forKey: .changedAt)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
        try container.encodeIfPresent(files, forKey: .files)
        if files == nil { try container.encodeNil(forKey: .files) }
    }
}
