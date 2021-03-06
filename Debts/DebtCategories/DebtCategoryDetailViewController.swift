import UIKit

class DebtCategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalDebtLabel: UILabel!
    @IBOutlet weak var numberOfDebtsLabel: UILabel!
    
    var debtCategory: DebtCategory?
    var debts: [Debt] = []
    var sortComparator = debtComparator {
        didSet {
            sortDebts()
        }
    }
    
    var keyboardObserver: NSObjectProtocol?
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    private static let nameComparator: (Debt, Debt) -> Bool = {
        guard let person = $0.person, let p2 = $1.person else { return false }
        return person.name.lowercased() < p2.name.lowercased()
    }
    private static let debtComparator: (Debt, Debt) -> Bool = { $0.cost > $1.cost }
    private static let dateComparator: (Debt, Debt) -> Bool = { $0.dateAdded > $1.dateAdded }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let debtCategory = debtCategory else { return }
        
        title = debtCategory.name
        
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        tableView.register(UINib(nibName: Constants.Cells.debtDetailCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.debtDetailCell)
        
        keyboardObserver = registerKeyboardObserver(bottomConstraint: tableViewBottomConstraint)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPeople))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebts), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
        setComparator()
        
        reloadDebts()
    }
    
    func setComparator() {
        switch UserDefaults.standard.integer(forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator) {
        case 0:
            sortComparator = DebtCategoryDetailViewController.nameComparator
        case 1:
            sortComparator = DebtCategoryDetailViewController.debtComparator
        case 2:
            sortComparator = DebtCategoryDetailViewController.dateComparator
        default:
            break
        }
    }
    
    @objc func tapAction() {
        view.endEditing(true)
    }
    
    func sortDebts() {
        debts.sort(by: sortComparator)
        tableView.reloadData()
    }
    
    @objc func addPeople() {
        guard let debtCategory = debtCategory else { return }
        
        let vc = UIStoryboard(name: Constants.Storyboard.main, bundle: nil).instantiateViewController(ofType: NewDebtViewController.self, withIdentifier: Constants.Storyboard.newDebtViewController)
        
        vc.debtCategory = debtCategory
        
        //Return people that are not already added to that debt
        vc.people = RealmHelper.getAllPersons().filter { (person) -> Bool in
            var containsDebt = false
            person.debts.forEach({ (debt) in
                if debtCategory.debts.contains(debt) {
                    containsDebt = true
                }
            })
            return !containsDebt
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func reloadDebts() {
        guard let debtCategory = debtCategory else { return }
        
        debts = RealmHelper.getDebts(for: debtCategory)
        sortDebts()
        
        totalDebtLabel.text = Currency.stringWithSelectedCurrency(for: debtCategory.totalDebt)
        numberOfDebtsLabel.text = "\(debtCategory.debts.count) debt\(debtCategory.debts.count == 1 ? "" : "s")"
        
        tableView.reloadData()
    }
    
    @IBAction func sortAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: NSLocalizedString("sort_by", comment: ""), preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("name", comment: ""), style: .default, handler: { (_) in
            self.sortComparator = DebtCategoryDetailViewController.nameComparator
            UserDefaults.standard.set(0, forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("debt", comment: ""), style: .default, handler: { (_) in
            self.sortComparator = DebtCategoryDetailViewController.debtComparator
            UserDefaults.standard.set(1, forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("date_added", comment: ""), style: .default, handler: { (_) in
            self.sortComparator = DebtCategoryDetailViewController.dateComparator
            UserDefaults.standard.set(2, forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension DebtCategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: DebtDetailTableViewCell.self, withIdentifier: Constants.Cells.debtDetailCell, for: indexPath)
        
        cell.delegate = self
        cell.setupForDebtCategoryDetails(with: debts[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: NSLocalizedString("delete", comment: "")) { (_, _, completionHandler) in
            RealmHelper.removeDebt(self.debts[indexPath.row])
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            completionHandler(true)
        }
        delete.backgroundColor = .red
        
        let edit = UIContextualAction(style: .normal, title: NSLocalizedString("edit_cost", comment: "")) { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? DebtDetailTableViewCell else { return }
            
            cell.editCost()
            completionHandler(true)
        }
        edit.backgroundColor = .gray
        
        let config = UISwipeActionsConfiguration(actions: [delete, edit])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
}

extension DebtCategoryDetailViewController: DebtDetailTableViewCellDelegate {
    func debtDetailTableViewCell(_ cell: DebtDetailTableViewCell, didUpdateCost cost: Double) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        RealmHelper.changeCost(for: debts[indexPath.row], cost: cost)
        NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
    }
    
    func debtDetailTableViewCellDidCancel(_ cell: DebtDetailTableViewCell) {
        reloadDebts()
    }
}
