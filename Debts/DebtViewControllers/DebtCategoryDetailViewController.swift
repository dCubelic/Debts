import UIKit

class DebtCategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var totalDebtLabel: UILabel!
    @IBOutlet weak var numberOfDebtsLabel: UILabel!
    
    var debtCategory: DebtCategory?
    var debts: [Debt] = []
    
    var keyboardObserver: NSObjectProtocol?
    deinit {
        if let keyboardObserver = keyboardObserver {
            NotificationCenter.default.removeObserver(keyboardObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "paper_pattern"))
        
        keyboardObserver = NotificationCenter.default.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: { (notification) in
            if let userInfo = notification.userInfo,
                //                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
                let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                
                if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
                    self.tableViewBottomConstraint.constant = UIScreen.main.bounds.height - endFrameValue.cgRectValue.minY - tabBarHeight
                }
                
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions(rawValue: UInt(curve.intValue << 16)), animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPeople))
        
        tableView.register(UINib(nibName: Constants.debtDetailCell, bundle: nil), forCellReuseIdentifier: Constants.debtDetailCell)
        
        guard let debtCategory = debtCategory else { return }
        
        underlineView.backgroundColor = UIColor(for: debtCategory)
        title = debtCategory.name
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDebts), name: Notification.Name(Constants.Notifications.updatedDatabase), object: nil)
        
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
        
//        var dc: [Person: Double] = [:]
//        for debt in debtCategory.debts {
//            if let person = debt.person {
//                dc[person] = debt.cost
//            }
//        }
//        vc.costDict = [:]
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func reloadDebts() {
        guard let debtCategory = debtCategory else { return }
        
        debts = RealmHelper.getDebts(for: debtCategory)
        
        totalDebtLabel.text = String(
            format: "%@%.2f%@",
            Constants.currencyBeforeValue ? Constants.currency : "",
            debtCategory.totalDebt,
            Constants.currencyBeforeValue ? "" : Constants.currency
        )
        numberOfDebtsLabel.text = "\(debtCategory.debts.count) debt\(debtCategory.debts.count == 1 ? "" : "s")"
        
        tableView.reloadData()
    }
    
}

extension DebtCategoryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return debts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: DebtDetailTableViewCell.self, withIdentifier: Constants.debtDetailCell, for: indexPath)
        //        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.debtDetailCell, for: indexPath) as! DebtDetailTableViewCell
        
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
        
        let edit = UIContextualAction(style: .normal, title: "Edit\nCost") { (_, _, completionHandler) in
            guard let cell = tableView.cellForRow(at: indexPath) as? DebtDetailTableViewCell else { return }
            
            cell.editCost()
            completionHandler(true)
        }
        
        delete.backgroundColor = .red
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
}
