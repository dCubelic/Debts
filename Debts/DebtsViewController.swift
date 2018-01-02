import UIKit

class DebtsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var debtCategories: [DebtCategory] = []
    var filteredDebtCategories: [DebtCategory] = []
    var sortComparator: (DebtCategory, DebtCategory) -> Bool = nameComparator
    
    private static let nameComparator: (DebtCategory, DebtCategory) -> Bool = { $0.name < $1.name }
    private static let dateComparator: (DebtCategory, DebtCategory) -> Bool = { $0.dateCreated > $1.dateCreated }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Debts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Debts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebtCategories), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        reloadDebtCategories()
    }
    
    @objc func reloadDebtCategories() {
        debtCategories = RealmHelper.getAllDebtCategories()
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
    
}

extension DebtsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDebtCategories.count
        }
        
        return debtCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: Constants.detailCell)

        var debtCategory: DebtCategory
        if isFiltering() {
            debtCategory = filteredDebtCategories[indexPath.row]
        } else {
            debtCategory = debtCategories[indexPath.row]
        }
        
        cell.textLabel?.text = debtCategory.name
        cell.detailTextLabel?.text = String(RealmHelper.getCost(for: debtCategory))
        
        return cell
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

extension DebtsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterDebtCategories(for: searchText)
        }
    }
}
