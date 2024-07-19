//
//  TodoListViewController.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 01.07.2024.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class TodoListViewController: UIViewController {
    
    private lazy var builder = {
        return ViewBuilder(viewController: self, toDoService: ToDoService(networkingService: DefaultNetworkingService(token: Constants.token)))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backPrimary
        
        builder.getDatesSlider()
        builder.getItemsTable()
    }
    
    func updatePage() async {
        await builder.updatePage()
    }
}
