//
//  Builder+TableView.swift
//  ToDo App
//
//  Created by Мирсаит Сабирзянов on 03.07.2024.
//

import Foundation
import UIKit

extension ViewBuilder: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].todo.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // let todoItem = sections[indexPath.section].todo[indexPath.row]
        // scrollToDate(for: todoItem)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! TodoItemCell
        let todoItem = sections[indexPath.section].todo[indexPath.row]
        cell.configure(with: todoItem)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedDateForVisibleSection()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .backPrimary

        let titleLabel = UILabel()
        titleLabel.text = sections[section].title
        titleLabel.textColor = .labelTertiary
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let uncompleteAction = UIContextualAction(style: .normal, title: "Uncomplete") { [weak self] (action, view, completionHandler) in
            self?.toggleTodoItemCompletion(at: indexPath, value: false)
            completionHandler(true)
        }
        uncompleteAction.image = UIImage(systemName: "multiply.circle")
        uncompleteAction.backgroundColor = .colorGray
        return UISwipeActionsConfiguration(actions: [uncompleteAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] (action, view, completionHandler) in
            self?.toggleTodoItemCompletion(at: indexPath, value: true)
            completionHandler(true)
        }
        completeAction.image = UIImage(systemName: "checkmark.circle")
        completeAction.backgroundColor = .colorGreen
        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    func toggleTodoItemCompletion(at indexPath: IndexPath, value: Bool) {
        let id = sections[indexPath.section].todo[indexPath.row].id
        let isCompleted = sections[indexPath.section].todo[indexPath.row].isCompleted

        guard value != isCompleted else { return }

        fileCache.updateTodoItem(id: id, isCompleted: value, to: Constants.fileName.rawValue)

        DispatchQueue.main.async { [weak self] in
            self?.manager.loadItem {
                guard let self = self else { return }
                self.sections = self.manager.groupedSectionsByDate()
                self.itemsTable?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
