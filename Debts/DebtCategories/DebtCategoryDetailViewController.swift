import UIKit

class DebtCategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineView: UIView!
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
        
        underlineView.backgroundColor = UIColor(for: debtCategory)
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        tableView.register(UINib(nibName: Constants.Cells.debtDetailCell, bundle: nil), forCellReuseIdentifier: Constants.Cells.debtDetailCell)
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
                    self.tableViewBottomConstraint.constant = UIScreen.main.bounds.height - endFrameValue.cgRectValue.minY - tabBarHeight
                }
                
                UIView.animate(withDuration: durationValue.doubleValue, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPeople))
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebts), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
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
        
        reloadDebts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let debtCategory = debtCategory else { return }
        
        navigationController?.navigationBar.tintColor = UIColor(for: debtCategory)
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
        let actionSheet = UIAlertController(title: nil, message: "Sort by:", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Name", style: .default, handler: { (_) in
            self.sortComparator = DebtCategoryDetailViewController.nameComparator
            UserDefaults.standard.set(0, forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator)
        }))
        actionSheet.addAction(UIAlertAction(title: "Debt", style: .default, handler: { (_) in
            self.sortComparator = DebtCategoryDetailViewController.debtComparator
            UserDefaults.standard.set(1, forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator)
        }))
        actionSheet.addAction(UIAlertAction(title: "Date Added", style: .default, handler: { (_) in
            self.sortComparator = DebtCategoryDetailViewController.dateComparator
            UserDefaults.standard.set(2, forKey: Constants.UserDefaults.debtCategoryDetailsSortComparator)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
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
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            RealmHelper.removeDebt(self.debts[indexPath.row])
            
            NotificationCenter.default.post(name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
            completionHandler(true)
        }
        delete.backgroundColor = .red
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nCost") { (_, _, completionHandler) in
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
