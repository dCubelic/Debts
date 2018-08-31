import UIKit

class MyDebtCategoriesViewController: UIViewController {
    
    enum MyDebtCategoriesControllerState {
        case defaultState, addingState, editingState
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var debtCategories: [DebtCategory] = [] {
        didSet {
            filteredDebtCategories = debtCategories
        }
    }
    var filteredDebtCategories: [DebtCategory] = []
    var sortComparator = dateComparator {
        didSet {
            sortDebtCategories()
        }
    }
    var didCancel = false
    var state: MyDebtCategoriesControllerState = .defaultState {
        didSet {
            if state == .defaultState {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction(_:)))
                navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "Sort")
            } else if state == .addingState || state == .editingState {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("done", comment: ""), style: .done, target: self, action: #selector(doneEditting))
                navigationItem.leftBarButtonItem?.image = nil
                navigationItem.leftBarButtonItem?.title = NSLocalizedString("cancel", comment: "")
            }
        }
    }
    
    var keyboardObserver: NSObjectProtocol?
    
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    private static let nameComparator: (DebtCategory, DebtCategory) -> Bool = { $0.name.lowercased() < $1.name.lowercased() }
    private static let totalDebtComparator: (DebtCategory, DebtCategory) -> Bool = { $0.totalDebt > $1.totalDebt }
    private static let dateComparator: (DebtCategory, DebtCategory) -> Bool = { $0.dateCreated > $1.dateCreated }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("my_debts", comment: "")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doneEditting))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        tableView.register(UINib(nibName: Constants.Cells.categoryCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.categoryCell)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebtCategories), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        keyboardObserver = registerKeyboardObserver(bottomConstraint: tableViewBottomConstraint)
        
        setupSearch()
        setComparator()
        
        reloadDebtCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadDebtCategories()
        navigationController?.navigationBar.tintColor = nil
    }
    
    func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search_categories", comment: "")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setComparator() {
        switch UserDefaults.standard.integer(forKey: Constants.UserDefaults.myDebtCategoriesSortComparator) {
        case 0:
            sortComparator = MyDebtCategoriesViewController.nameComparator
        case 1:
            sortComparator = MyDebtCategoriesViewController.totalDebtComparator
        case 2:
            sortComparator = MyDebtCategoriesViewController.dateComparator
        default:
            break
        }
    }
    
    @objc func doneEditting() {
        view.endEditing(true)
    }
    
    @objc func reloadDebtCategories() {
        debtCategories = RealmHelper.getAllMyDebtCategories()
        sortDebtCategories()
        
        if let searchText = searchController.searchBar.text {
            filterDebtCategories(for: searchText)
        }
    }
    
    func sortDebtCategories() {
        filteredDebtCategories.sort(by: sortComparator)
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterDebtCategories(for searchText: String) {
        if !isFiltering() {
            filteredDebtCategories = debtCategories
        } else {
            filteredDebtCategories = debtCategories.filter({ (debtCategory) -> Bool in
                return debtCategory.name.lowercased().contains(searchText.lowercased())
            })
        }
        
        tableView.reloadData()
    }
    
    @IBAction func addAction(_ sender: Any) {
        let newDebtCategory = DebtCategory()
        newDebtCategory.isMyDebt = true
        
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
            let actionSheet = UIAlertController(title: NSLocalizedString("sort_by", comment: ""), message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("name", comment: ""), style: .default, handler: { (_) in
                self.sortComparator = MyDebtCategoriesViewController.nameComparator
                UserDefaults.standard.set(0, forKey: Constants.UserDefaults.myDebtCategoriesSortComparator)
            }))
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("total_debt", comment: ""), style: .default, handler: { (_) in
                self.sortComparator = MyDebtCategoriesViewController.totalDebtComparator
                UserDefaults.standard.set(1, forKey: Constants.UserDefaults.myDebtCategoriesSortComparator)
            }))
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("date_created", comment: ""), style: .default, handler: { (_) in
                self.sortComparator = MyDebtCategoriesViewController.dateComparator
                UserDefaults.standard.set(2, forKey: Constants.UserDefaults.myDebtCategoriesSortComparator)
            }))
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
            
            present(actionSheet, animated: true, completion: nil)
        } else {
            didCancel = true
            view.endEditing(true)
        }
    }
}

extension MyDebtCategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if debtCategories.count == 0 {
            emptyTableViewLabel.isHidden = false
        } else {
            emptyTableViewLabel.isHidden = true
        }
        
        return filteredDebtCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: DebtCategoryTableViewCell.self, withIdentifier: Constants.Cells.categoryCell, for: indexPath)
        
        let debtCategory = filteredDebtCategories[indexPath.row]
        
        cell.delegate = self
        cell.setup(with: debtCategory)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: DebtCategoryDetailViewController.self, withIdentifier: Constants.Storyboard.debtCategoryDetailViewController)
        
        let debtCategory = filteredDebtCategories[indexPath.row]
        vc.debtCategory = debtCategory
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { (_, _, completionHandler) in
            let debtCategory = self.filteredDebtCategories[indexPath.row]
            
            let alert = UIAlertController(title: NSLocalizedString("remove_debt?", comment: ""), message: NSLocalizedString("are_you_sure_remove", comment: "") + " '\(debtCategory.name)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive, handler: { (_) in
                RealmHelper.removeDebtCategory(debtCategory: debtCategory)
                NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            completionHandler(false)
        }
        delete.backgroundColor = .red
        
        let edit = UIContextualAction(style: .normal, title: NSLocalizedString("edit_name", comment: "")) { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? DebtCategoryTableViewCell else { return }
            
            cell.editTitle()
            self.state = .editingState
            
            completionHandler(true)
        }
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
}

extension MyDebtCategoriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterDebtCategories(for: searchText)
        }
    }
}

extension MyDebtCategoriesViewController: DebtCategoryTableViewCellDelegate {
    func debtCategoryTableViewCellDidEndEditing(_ cell: DebtCategoryTableViewCell, title: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if didCancel || title.isEmpty {
            didCancel = false
            state = .defaultState
            reloadDebtCategories()
            return
        }
        
        let debtCategory = filteredDebtCategories[indexPath.row]
        
        RealmHelper.changeTitle(for: debtCategory, title: title)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        if state == .addingState {
            let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: NewDebtViewController.self, withIdentifier: Constants.Storyboard.newDebtViewController)
            vc.debtCategory = debtCategory
            vc.people = RealmHelper.getAllPersons()
            
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true, completion: nil)
        }
        
        didCancel = false
        state = .defaultState
    }
}
