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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        title = "Debts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Categories"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.register(UINib(nibName: Constants.categoryCell, bundle: nil), forCellReuseIdentifier: Constants.categoryCell)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebtCategories), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        reloadDebtCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadDebtCategories()
        navigationController?.navigationBar.tintColor = nil
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
    @objc func reloadDebtCategories() {
        debtCategories = RealmHelper.getAllDebtCategories()
        sortDebtCategories()
        if let searchText = searchController.searchBar.text {
            filterDebtCategories(for: searchText)
        }
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
    
    @IBAction func addAction(_ sender: Any) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.newDebtViewController)
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
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
        
        cell.delegate = self
        cell.setup(with: debtCategory)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.debtCategoryDetailViewController) as! DebtCategoryDetailViewController
        
        var debtCategory: DebtCategory
        if isFiltering() {
            debtCategory = filteredDebtCategories[indexPath.row]
        } else {
            debtCategory = debtCategories[indexPath.row]
        }
        
        vc.debtCategory = debtCategory
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        var debtCategory: DebtCategory
//        if isFiltering() {
//            debtCategory = filteredDebtCategories[indexPath.row]
//        } else {
//            debtCategory = debtCategories[indexPath.row]
//        }
//
//        if editingStyle == .delete {
//            if isFiltering() {
//                if let index = debtCategories.index(of: filteredDebtCategories[indexPath.row]) {
//                    debtCategories.remove(at: index)
//                }
//                filteredDebtCategories.remove(at: indexPath.row)
//            } else {
//                debtCategories.remove(at: indexPath.row)
//            }
//
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            RealmHelper.removeDebtCategory(debtCategory: debtCategory)
//
//            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
//        }
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            var debtCategory: DebtCategory
            if self.isFiltering() {
                debtCategory = self.filteredDebtCategories[indexPath.row]
            } else {
                debtCategory = self.debtCategories[indexPath.row]
            }
            
            RealmHelper.removeDebtCategory(debtCategory: debtCategory)
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            
            completionHandler(true)
        }
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nName") { (action, view, completionHandler) in
            let cell = tableView.cellForRow(at: indexPath) as! DebtCategoryTableViewCell
            
            cell.editTitle()
            
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
}

extension DebtCategoriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterDebtCategories(for: searchText)
        }
    }
}

extension DebtCategoriesViewController: DebtCategoryTableViewCellDelegate {
    func debtCategoryTableViewCell(_ cell: DebtCategoryTableViewCell, didChangeTitleTo title: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        var debtCategory: DebtCategory
        if self.isFiltering() {
            debtCategory = self.filteredDebtCategories[indexPath.row]
        } else {
            debtCategory = self.debtCategories[indexPath.row]
        }
        
        RealmHelper.changeTitle(for: debtCategory, title: title)
        
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
    }
}
