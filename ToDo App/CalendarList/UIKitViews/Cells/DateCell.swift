//
//  DateCollectionViewCell.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 02.07.2024.
//

import Foundation
import UIKit

class DateCell: UICollectionViewCell {
    
    let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        dateLabel.textColor = .labelTertiary
        dateLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        dateLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        layer.cornerRadius = 10
    }
    
    func configure(with date: String?) {
        guard let date else { return }
        let dateArr = date.split(separator: " ").map { String($0) }
        if dateArr.count == 2 {
            dateLabel.text = "\(dateArr[0])\n\(dateArr[1])"
        } else {
            dateLabel.text = date
        }
    }
}
