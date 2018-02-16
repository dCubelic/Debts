import UIKit

class DebtCategoriesViewController: UIViewController {
    
    enum DebtCategoriesControllerState {
        case defaultState, addingState, editingState
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var debtCategories: [DebtCategory] = []
    var filteredDebtCategories: [DebtCategory] = []
    var sortComparator: (DebtCategory, DebtCategory) -> Bool = dateComparator
    
    var state: DebtCategoriesControllerState = .defaultState {
        didSet {
            if state == .defaultState {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction(_:)))
                navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "Sort")
            } else if state == .addingState {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneEditting))
                navigationItem.leftBarButtonItem?.image = nil
                navigationItem.leftBarButtonItem?.title = "Cancel"
            }
        }
    }
    
    private static let nameComparator: (DebtCategory, DebtCategory) -> Bool = { $0.name.lowercased() < $1.name.lowercased() }
    private static let totalDebtComparator: (DebtCategory, DebtCategory) -> Bool = { $0.totalDebt > $1.totalDebt }
    private static let dateComparator: (DebtCategory, DebtCategory) -> Bool = { $0.dateCreated > $1.dateCreated }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doneEditting))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        title = "Debts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
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
    
    @objc func doneEditting() {
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
        let newDebtCategory = DebtCategory()
        let indexPath = IndexPath(row: 0, section: 0)
        
        debtCategories.insert(newDebtCategory, at: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? DebtCategoryTableViewCell else { return }
        cell.editTitle()
        
        state = .addingState
    }
    @IBAction func leftBarButtonAction(_ sender: Any) {
        if state == .defaultState {
            let actionSheet = UIAlertController(title: "Sort by:", message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Name", style: .default, handler: { (_) in
                self.sortComparator = DebtCategoriesViewController.nameComparator
                self.sortDebtCategories()
            }))
            actionSheet.addAction(UIAlertAction(title: "Total Debt", style: .default, handler: { (_) in
                self.sortComparator = DebtCategoriesViewController.totalDebtComparator
                self.sortDebtCategories()
            }))
            actionSheet.addAction(UIAlertAction(title: "Date Created", style: .default, handler: { (_) in
                self.sortComparator = DebtCategoriesViewController.dateComparator
                self.sortDebtCategories()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            reloadDebtCategories()
            tableView.isUserInteractionEnabled = true
            state = .defaultState
        }
    }
}

extension DebtCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDebtCategories.count
        }
        
        return debtCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: DebtCategoryTableViewCell.self, withIdentifier: Constants.categoryCell, for: indexPath)
        //        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.categoryCell, for: indexPath) as! DebtCategoryTableViewCell
        
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
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: DebtCategoryDetailViewController.self, withIdentifier: Constants.Storyboard.debtCategoryDetailViewController)
        //        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(withIdentifier: Constants.Storyboard.debtCategoryDetailViewController) as! DebtCategoryDetailViewController
        
        var debtCategory: DebtCategory
        if isFiltering() {
            debtCategory = filteredDebtCategories[indexPath.row]
        } else {
            debtCategory = debtCategories[indexPath.row]
        }
        
        vc.debtCategory = debtCategory
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
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
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nName") { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? DebtCategoryTableViewCell else { return }
            
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
        
        if state == .addingState {
            let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: NewDebtViewController.self, withIdentifier: Constants.Storyboard.newDebtViewController)
            vc.debtCategory = debtCategory
            vc.people = RealmHelper.getAllPersons()
            
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true, completion: nil)
        }
        
        state = .defaultState
    }
    
    func debtCategoryTableViewCellDidCancel(_ cell: DebtCategoryTableViewCell) {
        reloadDebtCategories()
        state = .defaultState
    }
}
