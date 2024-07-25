//
//  TodoItem+Codable.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 25.07.2024.
//

import Foundation

extension TodoItem {
    
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
