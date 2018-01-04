import UIKit

class DebtCategoriesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var debtCategories: [DebtCategory] = []
    var filteredDebtCategories: [DebtCategory] = []
    var sortComparator: (DebtCategory, DebtCategory) -> Bool = dateComparator
    
    var colors: [UIColor] = [
        .red, .blue, .yellow, .brown, .green, .gray, .purple, .orange, .magenta
    ]
    var colorMap: [DebtCategory: UIColor] = [:]
    
    private static let nameComparator: (DebtCategory, DebtCategory) -> Bool = { $0.name.lowercased() < $1.name.lowercased() }
    private static let totalDebtComparator: (DebtCategory, DebtCategory) -> Bool = { $0.totalDebt > $1.totalDebt }
    private static let dateComparator: (DebtCategory, DebtCategory) -> Bool = { $0.dateCreated > $1.dateCreated }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categories"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.register(UINib(nibName: Constants.categoryCell, bundle: nil), forCellReuseIdentifier: Constants.categoryCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 75
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebtCategories), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        reloadDebtCategories()
    }
    
    @objc func reloadDebtCategories() {
        debtCategories = RealmHelper.getAllDebtCategories()
        sortDebtCategories()
    }
    
    func sortDebtCategories() {
        debtCategories.sort(by: sortComparator)
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterDebtCategories(for searchText: String) {
        filteredDebtCategories = debtCategories.filter({ (debtCategory) -> Bool in
            return debtCategory.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }

    @IBAction func editAction(_ sender: Any) {
        guard let barButton = sender as? UIBarButtonItem else { return }
        
        if tableView.isEditing {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = nil
            barButton.style = .plain
            barButton.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .clear
            barButton.style = .done
            barButton.title = "Cancel"
            tableView.setEditing(true, animated: true)
        }
    }
    
    @IBAction func sortAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Name", style: .default, handler: { (alertAction) in
            self.sortComparator = DebtCategoriesViewController.nameComparator
            self.sortDebtCategories()
        }))
        actionSheet.addAction(UIAlertAction(title: "Total Debt", style: .default, handler: { (alertAction) in
            self.sortComparator = DebtCategoriesViewController.totalDebtComparator
            self.sortDebtCategories()
        }))
        actionSheet.addAction(UIAlertAction(title: "Date Created", style: .default, handler: { (alertAction) in
            self.sortComparator = DebtCategoriesViewController.dateComparator
            self.sortDebtCategories()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension DebtCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDebtCategories.count
        }
        
        return debtCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCell, for: indexPath) as! DebtCategoryTableViewCell
        
        var debtCategory: DebtCategory
        if isFiltering() {
            debtCategory = filteredDebtCategories[indexPath.row]
        } else {
            debtCategory = debtCategories[indexPath.row]
        }
        
        cell.setup(with: debtCategory)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var debtCategory: DebtCategory
        if isFiltering() {
            debtCategory = filteredDebtCategories[indexPath.row]
        } else {
            debtCategory = debtCategories[indexPath.row]
        }
        
        if editingStyle == .delete {
            if isFiltering() {
                if let index = debtCategories.index(of: filteredDebtCategories[indexPath.row]) {
                    debtCategories.remove(at: index)
                }
                filteredDebtCategories.remove(at: indexPath.row)
            } else {
                debtCategories.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            RealmHelper.removeDebtCategory(debtCategory: debtCategory)
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        }
    }
    
}

extension DebtCategoriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterDebtCategories(for: searchText)
        }
    }
}
