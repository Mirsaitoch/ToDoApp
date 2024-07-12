//
//  ViewBuilder+CollectionView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 03.07.2024.
//

import Foundation
import UIKit

extension ViewBuilder: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uniqueDatesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DateCell else { return UICollectionViewCell() }
        
        let displayText: String
        
        displayText = uniqueDatesArray[indexPath.row] ?? "No Date"
        
        cell.configure(with: displayText)
        
        if indexPath == selectedDateIndex {
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.colorTelegraph.cgColor
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.backgroundColor = UIColor.colorSilk
        } else {
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.backgroundColor = UIColor.backPrimary
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate: String?
        if indexPath.row < uniqueDatesArray.count {
            selectedDate = uniqueDatesArray[indexPath.row]
        } else {
            selectedDate = "Другое"
        }
        selectedDateIndex = indexPath
        scrollToSection(for: selectedDate ?? "Другое")
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
