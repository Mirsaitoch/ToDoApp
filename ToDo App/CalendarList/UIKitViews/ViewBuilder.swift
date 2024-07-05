import UIKit


final class ViewBuilder: NSObject {
    let manager = ViewManager.shared

    private let dateFormatter = DateConverter()
    let fileCache = FileCache.shared
    var viewController: UIViewController
    var view: UIView

    var items = [TodoItem]()
    var uniqueDates = [Date?]()
    var uniqueDatesArray = [String?]()
    var sections = [TableSection]()

    private(set) var datesCollection: UICollectionView!
    private(set) var itemsTable: UITableView!
    
    private let dataQueue = DispatchQueue(label: "com.todoapp.dataQueue")
    var selectedDateIndex: IndexPath?

    init(viewController: UIViewController) {
        self.viewController = viewController
        self.view = viewController.view
        super.init()
        self.manager.loadItem 
        {
            self.reloadData()
        }
    }
    
    func updatePage() {
        self.manager.loadItem
        {
            self.reloadData()
        }
    }
    
    func reloadData() {
        dataQueue.async {
            self.uniqueDatesArray = self.manager.getSortedDates()

            self.sections = self.manager.groupedSectionsByDate()
            DispatchQueue.main.async {
                self.datesCollection.reloadData()
                self.itemsTable.reloadData()
            }
        }
    }

    func getDatesSlider() {
        datesCollection = manager.getCollection(id: "dates", dataSource: self, delegate: self)
        datesCollection.register(DateCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(datesCollection)
        
        datesCollection.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            datesCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datesCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            datesCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            datesCollection.heightAnchor.constraint(equalToConstant: 100) 
        ])
        
        addHorizontalSeparator(below: datesCollection)
    }
    
    func getItemsTable() {
        itemsTable = UITableView(frame: .zero, style: .insetGrouped)
        itemsTable.dataSource = self
        itemsTable.delegate = self
        itemsTable.register(TodoItemCell.self, forCellReuseIdentifier: "itemCell")
        itemsTable.showsVerticalScrollIndicator = false
        itemsTable.backgroundColor = .backPrimary

        view.addSubview(itemsTable)
        
        itemsTable.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            itemsTable.topAnchor.constraint(equalTo: datesCollection.bottomAnchor),
            itemsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func addHorizontalSeparator(below view: UIView) {
        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: view.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func updateSelectedDate(for date: String) {
        guard let collectionView = datesCollection else { return }
        
        for (index, uniqueDate) in uniqueDatesArray.enumerated() {
            if uniqueDate == date {
                let indexPath = IndexPath(row: index, section: 0)
                selectedDateIndex = indexPath
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                collectionView.reloadData()
                return
            }
        }
    }
    
    func scrollToSection(for date: String) {
        guard let tableView = itemsTable else { return }
        
        for (index, section) in sections.enumerated() {
            if section.title == date {
                let indexPath = IndexPath(row: 0, section: index)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                return
            }
        }
    }
    
    
    func updateSelectedDateForVisibleSection() {
        guard let tableView = itemsTable else { return }
        
        let visibleRows = tableView.indexPathsForVisibleRows ?? []
        let sortedVisibleRows = visibleRows.sorted()
        
        if let firstVisibleRow = sortedVisibleRows.first {
            let date = sections[firstVisibleRow.section].title
            updateSelectedDate(for: date)
        }
    }
}

