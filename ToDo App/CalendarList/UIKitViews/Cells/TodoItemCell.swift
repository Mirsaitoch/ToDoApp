//
//  TodoItemCell.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 03.07.2024.
//

import Foundation
import UIKit

class TodoItemCell: UITableViewCell {
    
    let todoLabel = UILabel()
    let importanceIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        todoLabel.translatesAutoresizingMaskIntoConstraints = false
        importanceIndicator.translatesAutoresizingMaskIntoConstraints = false
        importanceIndicator.layer.cornerRadius = 5
        importanceIndicator.layer.masksToBounds = true
        
        contentView.addSubview(todoLabel)
        contentView.addSubview(importanceIndicator)
        
        NSLayoutConstraint.activate([
            todoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            todoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            todoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            todoLabel.trailingAnchor.constraint(equalTo: importanceIndicator.leadingAnchor, constant: -10),
            
            importanceIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            importanceIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            importanceIndicator.widthAnchor.constraint(equalToConstant: 10),
            importanceIndicator.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    func configure(with item: TodoItem) {
        
        todoLabel.textColor = item.isCompleted ? .labelTertiary : .labelPrimary
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: item.text)
        
        if item.isCompleted {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
        }
        
        todoLabel.attributedText = attributeString
        
        switch item.category {
        case .standard(let standardCategory):
            switch standardCategory {
            case .work:
                importanceIndicator.backgroundColor = .red
            case .study:
                importanceIndicator.backgroundColor = .blue
            case .hobby:
                importanceIndicator.backgroundColor = .green
            case .other:
                importanceIndicator.backgroundColor = .gray
            }
        case .custom(let customCategory):
            importanceIndicator.backgroundColor = UIColor(customCategory.color)
        }
    }
}
